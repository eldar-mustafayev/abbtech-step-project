import os
import requests
from functools import cache, cached_property
from flask import Flask, render_template, Response

app = Flask(__name__)


class PhoneBook:
     
    COLUMN_MAP = {'user_id': 0, 'name': 1, 'phone': 2}

    def __init__(self, user_list) -> None:
        self.ncols = len(self.COLUMN_MAP)
        self.nrows = len(user_list)

        self._data = [[None] * self.ncols for _ in range(self.nrows)]
        for user_idx in range(self.nrows):
            for field, value in user_list[user_idx].items():

                col_idx = self.COLUMN_MAP[field]
                self._data[user_idx][col_idx] = value

    def __iter__(self):
        for row in self._data: yield row

    @cache
    def __getitem__(self, idx, field):
        col_idx = self.COLUMN_MAP[field]
        return self._data[idx][col_idx]

    @cached_property
    def columns(self):
        return list(self.COLUMN_MAP.keys())


@app.route('/')
def display_all():
    
    response = requests.get(f'http://{os.environ["BACKEND_HOST"]}:8080/user/list')
    data = response.json()
    phone_book = PhoneBook(data)

    return render_template('index.html', phone_book=phone_book)

@app.route("/status")
def status():
    return Response(status=200)


if __name__ == '__main__':
    app.run('0.0.0.0', 80)
