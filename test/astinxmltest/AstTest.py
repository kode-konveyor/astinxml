import unittest
import inspect
import sys
from astinxml.Documenter import Documenter
from xml.etree.ElementTree import fromstring

class Test(unittest.TestCase):

    def getCurrentPackage(self):
        module = inspect.getmodule(self)
        packageName, _sep, _stem = module.__name__.partition('.')
        package = sys.modules[packageName]
        return package

    def setUp(self):
        package = self.getCurrentPackage()
        documenter = Documenter()
        self.docTree=documenter.parse_module(package.__path__[0])
        self.etree = fromstring(self.docTree.toxml('utf-8'))
        self.rootNode=self.docTree.documentElement
        with open("/tmp/foo.xml", "w") as f:
            f.write(self.docTree.toprettyxml())
        
    def test_document_root_is_a_package_object(self):
        self.assertEqual("package", self.rootNode.localName)

    def test_name_attribute_of_package_is_the_package_name(self):
        self.assertEqual("astinxmltest", self.rootNode.attributes['name'].value)
    
    def test_subpackage_is_documented(self):
        self.assertEqual(1, len(self.etree.findall(".//package[@name='testPackage']")))

    def test_module_is_documented(self):
        self.assertEqual(1, len(self.etree.findall(
            ".//package[@name='testPackage']/Module[@name='DocumentedService.py']")))

    def test_class_decorator_is_documented(self):
        self.assertEqual(
            'Service',
            self.etree.findall(
                ".//package[@name='testPackage']//ClassDef[@name='DocumentedService']/decorator_list/Name"
            )[0].attrib['id'])
