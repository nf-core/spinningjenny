#!/usr/bin/env python 
__author__ = 'luca.cozzuto@crg.eu'
# -*- coding utf-8 -*-

import argparse
import xml.etree.ElementTree as ET
import os
import pprint
import sys


def argparse_args():

	parser = argparse.ArgumentParser(description='Change XML file')
	parser.add_argument('-t', action='store', dest='template', help='xml template')
	parser.add_argument('-o', action='store', dest='output', help='output.xml file')
	parser.add_argument('-n', action='store', dest='param', help='name(s) of the param(s) which value has to be changed. They can be comma separated')
	parser.add_argument('-v', action='store', dest='value', help='value(s) of the param(s) that has to be used. They can be comma separated')

	args = parser.parse_args()
	
	return (args)




def parse_stats(file, ids, vals, outfile):

	""" Parse xml file """

	results = {}
	tree = ET.parse(file)
	root = tree.getroot()
	for child1 in root:
		for child2 in child1:
			variable = child2.get('variable')
			if (variable in ids):
				index = ids.index(variable)
				new_value = vals[index]
				for child3 in child2:
					value = child3.get('value')
					child3.set('value', new_value)
					print(child3.attrib)
	tree.write(outfile)
	return 


if __name__ == "__main__":

	args = argparse_args()
	ids = args.param.split(",")
	vals = args.value.split(",")
	parse_stats(args.template, ids, vals, args.output)
