import pytest

from app import app
from flask.testing import FlaskClient


@pytest.fixture()
def client():
    app.config.update({
        "TESTING": True,
    })

    return app.test_client()

def test_db_connection(client: FlaskClient):
    with client:
        response = client.get('/status')

    assert response.status_code == 200, response.json

def test_list_users(client: FlaskClient):
    with client:
        response = client.get('/user/list')

    assert response.status_code == 200, response.json

def test_not_edit_user(client: FlaskClient):
    with client:
        response = client.put(
            '/user/edit',
            json={
                'name': 'Batman',
                'phone': '+994501000000'
            }
        )

    assert response.json is not None
    assert response.status_code != 200 and \
           response.json['operation_status'] == 'fail' and \
           response.json['operation_type'] == 'edit', response.json

def test_add_user(client: FlaskClient):
    with client:
        response = client.post(
            '/user/add',
            json={
                'user_id': 0,
                'name': 'Optimus Prime',
                'phone': '+994501234567'
            }
        )

    assert response.status_code == 200, response.json

def test_not_add_user(client: FlaskClient):
    with client:
        response = client.post(
            '/user/add',
            json={
                'user_id': 0,
                'name': 'Optimus Prime',
                'phone': '+994501234567'
            }
        )

    assert response.json is not None
    assert response.status_code != 200 and \
           response.json['operation_status'] == 'fail' and \
           response.json['operation_type'] == 'add', response.json

def test_edit_user(client: FlaskClient):
    with client:
        response = client.put(
            '/user/edit',
            json={
                'user_id': 0,
                'name': 'Batman',
                'phone': '+994501000000'
            }
        )

    assert response.status_code == 200, response.json

def test_delete_user(client: FlaskClient):
    with client:
        response = client.delete(
            '/user/delete',
            json={'user_id': 0}
        )

    assert response.status_code == 200, response.json

def test_not_delete_user(client: FlaskClient):
    with client:
        response = client.delete(
            '/user/delete',
        )

    assert response.json is not None
    assert response.status_code != 200 and \
           response.json['operation_status'] == 'fail' and \
           response.json['operation_type'] == 'delete', response.json

def test_exception_handler(client: FlaskClient):
    with client:
        response = client.delete(
            '/unknown/path',
            json={'user_id': 0}
        )

    assert response.json is not None
    assert response.json['operation_status'] == 'fail'