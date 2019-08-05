class Service(object):
    def __init__(self,param):
        pass

from _ast import AST

@Service
class DocumentedService(AST):
    def documentedMethod(self, params: list):
        self.params:list = params