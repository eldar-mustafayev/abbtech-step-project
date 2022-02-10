import pymysql
from pathlib import Path
from typing import Optional

from flask import Flask, request, jsonify

app = Flask(__name__)
connection = pymysql.connect(host='localhost', user='root', password='password', database='mysql')


def fix_path(path: str) -> Path:
    return Path(__file__).parent.resolve() / Path(path)

@app.errorhandler(Exception)
def handle_exception(error):

    data: Optional[dict] = request.get_json(silent=True)
    if data is None:
        data = {'user_id': None}

    operation_type = ""
    if request.path.startswith('/user/add'):
        operation_type = "add"
    elif request.path.startswith('/user/edit'):
        operation_type = "edit"
    elif request.path.startswith('/user/delete'):
        operation_type = 'delete'

    return jsonify({
        'user_id': data['user_id'],
        'operation_type': operation_type,
        'operation_status': "fail",
        "exception": repr(error),
    }) 


@app.route('/user/list', methods=['GET'])
def all_users():

    with connection.cursor() as cur:
        cur.execute('SELECT * FROM phonebook')

        columns = [field[0] for field in cur.description]
        response = [dict(zip(columns, row)) for row in cur]

    return jsonify(response)


@app.route('/user/add', methods=['POST'])
def add_user():

    data: dict = request.get_json(force=True)
    with connection.cursor() as cur:
        cur.execute(
            '''INSERT INTO phonebook VALUES (%s, %s, %s)''',
            (data.get('user_id'), data.get('name'), data.get('phone'))
            )
        connection.commit()

    return jsonify(
        user_id=data.get('user_id'),
        operation_type='add',
        operation_status='success'
    )


@app.route('/user/edit', methods=['PUT'])
def edit_user():

    data: dict = request.get_json(force=True)
    user_id = data['user_id']
    with connection.cursor() as cur:
        name = data.get('name')
        if name:
            cur.execute(
                'UPDATE phonebook SET name=%s WHERE user_id=%s',
                (name, user_id)
            )

        phone = data.get('phone')
        if phone:
            cur.execute(
                'UPDATE phonebook SET phone=%s WHERE user_id=%s',
                (phone, user_id)
            )

        connection.commit()

    return jsonify(
        user_id=data.get('user_id'),
        operation_type='edit',
        operation_status='success'
    )


@app.route('/user/delete', methods=['DELETE'])
def delete_user():

    data: dict = request.get_json(force=True)
    user_id = data['user_id']
    with connection.cursor() as cur:

        cur.execute(
            'DELETE FROM phonebook WHERE user_id=%s',
            user_id
        )

    return jsonify(
        user_id=data.get('user_id'),
        operation_type='delete',
        operation_status='success'
    )


query_path = fix_path('../database/createTable.sql')
with open(query_path) as query:
    with connection.cursor() as cur:
        cur.execute(query.read())
        connection.commit()


if __name__ == "__main__":
    app.run('0.0.0.0', 8080, debug=True)
    connection.close()

