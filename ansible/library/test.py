#!/usr/bin/python


def create_vars():
    global var_one
    global var_two
    var_one = "var1"
    var_two = "var2"
    dictionary = dict(name="test", required=True)
    return dictionary


def read_vars(dictionary):
    print var_one
    print var_two
    print dictionary


def main():
    read_vars(create_vars())


main()

dictionary = create_vars()
print dictionary
