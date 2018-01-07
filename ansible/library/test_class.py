#!/usr/bin/python


class Test(object):
    """ Test class
    """

    def create_vars(self):
        global var_one
        global var_two
        var_one = "var1"
        var_two = "var2"
        dictionary = dict(name="test", required=True)
        return(dictionary)

    def read_vars(self, dictionary):
        print var_one
        print var_two
        print dictionary

    def main(self):
        self.read_vars(self.create_vars())

test = Test()
test.main()
