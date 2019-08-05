from xml.dom.minidom import Document
from posixpath import split, join
from os.path import isdir, isfile
from posix import listdir
from astinxml.Visitor import Visitor
import ast

class Documenter(object):
    def __init__(self):
        self.document = Document()

    def createElement(self, path, parent, name):
        xmlNode = self.document.createElement(name)
        xmlNode.setAttribute('name', split(path)[-1])
        parent.appendChild(xmlNode)
        return xmlNode

    def parse_module(self, path, parent = None):
        if parent is None:
            parent = self.document
        xmlNode = self.createElement(path, parent, "package")
        if(isdir(path)):
            for fileName in listdir(path):
                fullPath = join(path, fileName)
                if fileName[0] != '_':
                    if isfile(fullPath):
                        self.astParse(fullPath, xmlNode)
                    elif isdir(fullPath):
                        self.parse_module(fullPath, xmlNode)
        return self.document
    
    def astParse(self, path, parent):
        visitor = Visitor(self.document, parent)
        with open(path, 'r') as file:
            content = file.read()
        tree = ast.parse(content,path)
        visitor.visit(tree)
        visitor.lastNode.setAttribute('name', split(path)[-1])
