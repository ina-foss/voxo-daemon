import json

class Response():

    def __init__(self, status_code=200, json_string='{}'):
        self.status_code = status_code
        self.json_string = json_string


    def json(self):
        return json.loads(self.json_string)

class Session():
    
    def __init__(self, response=None):
        if response:
            self.response = response
        else:
            self.response = Response()

    def mount(self, *args):
        return True

    def get(self, url, **kwargs):
        return self.response

    def put(self, url, **kwargs):
        return self.response

    def post(self, url, **kwargs):
        return self.response
