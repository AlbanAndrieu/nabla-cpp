#!/usr/bin/env python
# -*- coding: utf-8 -*-
#!/usr/bin/python2.4
#!/usr/bin/python
"""
==========================================================================
scons2dot.py
==========================================================================

This is a simple python program meant to vizualize build dependencies.
It grabs scons_ --tree=all output and converts it to a graphviz_ dot
graph. The current version of scons2dot.py is found
`here <http://www.cs.virginia.edu/~dww4s/tools/scons2dot/scons2dot.txt>`_
(HTML `<scons2dot.html>`_).

Example::

  +-call
    +-call.o
    | +-call.s
    | | +-call.c
    | | +-/usr/bin/g++
    | +-/usr/bin/g++
    +-/usr/bin/g++


  +-dbxml:call.o.xml
    +-call.o.xml
    | +-call.s
    | | +-call.c
    | | +-/usr/bin/g++
    | +-/home/dww4s/research/metaman/mm_v2/bin/metaman_asm.py
    +-scons.dbxml
    +-/home/dww4s/research/metaman/mm_v2/bin/manage_container

Gets converted to the following using dot:

.. dot:: builddep.dot

  digraph scons_graph {
  graph [rankdir="LR", bgcolor="transparent"]

        n0 [label="manage_container"]
        n1 [label="call.o.xml"]
        n2 [label="scons.dbxml"]
        n3 [color="red", label="dbxml:call.o.xml"]
        n4 [label="metaman_asm.py"]
        n5 [label="call.s"]
        n6 [label="call.o"]
        n7 [color="red", label="call"]
        n8 [label="g++"]
        n9 [label="call.c"]

        n4 -> n1
        n5 -> n1
        n0 -> n3
        n1 -> n3
        n2 -> n3
        n8 -> n5
        n9 -> n5
        n8 -> n6
        n5 -> n6
        n6 -> n7
        n8 -> n7

  }

Using the command::

  scons --tree=all -n | scons2dot.py

Note that scons2dot.py uses the basename of the entry as the label, though
the entire string is stored in the Node data structure. If the ``--save``
option is used, the dot output is saved to a temp file, dot is invoked, and
the resulting file is saved, as specified by ``--outfile``.

Invoke scons2dot.py -h for more info on command options.

TODO
==========================================================================

- Add support for the --tree=all,status option, coloring built nodes, etc.

----

:author: Dan Williams (dan_williams@cs.virginia.edu)
:Homepage: http://www.cs.virginia.edu/~dww4s
:Last doc rebuild: |date|
:copyright: University of Virginia, 2009
:license: BSD_
:version: 0.1
:python version: `2.4 <http://www.python.org/download/releases/2.4.6/>`_

.. _BSD: http://www.opensource.org/licenses/bsd-license.php
.. _scons: http://www.scons.org/
.. _graphviz: http://www.graphviz.org/

.. |date| date:: %m-%d-%y
"""

cmd_line_usage = \
    """
Usage: %prog [options]

%prog reads the output from scons with the --tree=all option, and produces
dot code that can be used to create a visualization of your build
dependencies. The easiest way to use %prog is to pipe the output from scons
to %prog, and use the --save and --outfile options to store the resulting
pdf.

Example:

scons --tree=all -n | %prog --save --outfile deps.pdf
"""[1:-1]  # (removes first&last newline)

# Note: Command to build the __doc__ file (assuming rst2html, with a "dot"
# extension):
# python -c "import scons2dot; print scons2dot.__doc__" > scons2dot.rst
# rst2html scons2dot.rst scons2dot.html

##########################################################################
# Std. imports
##########################################################################
import re
import sys
import os.path
import sets
import tempfile


##########################################################################
# Defaults
##########################################################################
GRAPH_DEFAULTS = {
    'bgcolor': 'transparent',
    'rankdir': 'LR',
}

##########################################################################
# Classes
##########################################################################


class DotBuilder(object):
    """
    Build a dot for output. This class assumes the trees argument
    is a list of Node objects. It looks for a few other parameters
    related to dot building.
    """

    def __init__(self, trees=[], **kw):
        self.trees = trees
        self.nodes = []
        self.graph_name = kw.get('graph_name', 'scons_graph')
        self.graph_attrs = GRAPH_DEFAULTS
        self.graph_attrs.update(kw.get('graph_attrs', {}))
        self.node_attrs = kw.get('node_attrs', {})
        self.edge_attrs = kw.get('edge_attrs', {})
        self.fd = kw.get('fd', sys.stdout)
        self.dot_fname = kw.get('dot_fname', 'scons-dep.pdf')
        self.dot_format = kw.get('dot_format', 'pdf')
        self.dot_cmd = 'dot -T%(dot_format)s -o %(dot_fname)s'
        self.ignore_list = kw.get('ignore_list', [])
        self.verbose = bool(kw.get('verbose', True))
        self.ignore_re = [re.compile(x) for x in self.ignore_list]

    def dict2attrs(self, attrs):
        """
        Converts a dictionary to a list k="value",...; the format
        used by attributes in dot.
        """
        return ', '.join(['%s="%s"' % x for
                          x in attrs.items()])

    def _gather_nodes(self):
        """
        A simple bfs worklist to gather all unique nodes from
        the self.trees data structure.
        """
        results = sets.Set(self.trees)
        change = True
        work_list = self.trees[:]
        while len(work_list) > 0:
            item = work_list.pop()
            s = sets.Set(item.children)
            s = s - results
            work_list.extend(list(s))
            results = results.union(s)
        self.nodes = list(results)
        self._set_ignores()
        # print self.nodes
        return results

    def _set_ignores(self):
        """
        Processes and sets the ignored nodes.
        """
        for node in self.nodes:
            for ire in self.ignore_re:
                if ire.match(node.name):
                    node.ignore = True

    def save_graph(self):
        """
        Save the graph as temp file an invoke dot to
        create a graph is the format self.dot_format,
        and with the name self.dot_fname.
        """
        self.fd, fname = tempfile.mkstemp('.dot')
        self.fd = os.fdopen(self.fd, 'w')
        self.print_graph()
        self.fd.close()

        #(the following is a cheap trick to do str replacement
        # using this object's dictionary as the replacement.)
        cmd = self.dot_cmd % self.__dict__
        cmd += ' %s' % fname
        if self.verbose:
            print cmd
        os.system(cmd)

    def print_graph(self):
        """
        Prints the graph to self.fd.
        """
        self._gather_nodes()
        self._begin_graph()
        self._print_nodes()
        self._print_edges()
        self._end_graph()

    def _begin_graph(self):
        self.fd.write('digraph %s {\n' % self.graph_name)
        attr_strn = self.dict2attrs(self.graph_attrs)
        self.fd.write('graph [%s]\n\n' % attr_strn)

    def _print_nodes(self):
        if len(self.node_attrs):
            attr_strn = self.dict2attrs(self.node_attrs)
            self.fd.write('node [%s]\n' % attr_strn)
        for ind, node in enumerate(self.nodes):
            if node.ignore:
                continue
            node.id = 'n%d' % ind
            attrs = {'label': os.path.basename(node.name)}
            if node in self.trees:
                attrs['color'] = 'red'
            self.fd.write('\t%s [%s]\n' %
                          (node.id, self.dict2attrs(attrs)))
        self.fd.write('\n')

    def _print_edges(self):
        if len(self.edge_attrs):
            attr_strn = self.dict2attrs(self.edge_attrs)
            self.fd.write('edge [%s]\n' % attr_strn)

        for node in self.nodes:
            if node.ignore:
                continue
            for child in node.children:
                if child.ignore:
                    continue
                self.fd.write('\t%s -> %s\n' % (child.id, node.id))

    def _end_graph(self):
        self.fd.write('\n}\n')


class NullFD(object):
    def write(self, strn): pass

    def close(self): pass


class SConsForestParser(object):
    """
    A simple class that takes a file-like object and does
    basic regex scans for lines that appear to be
    """
    L1RE = re.compile(r'^\+-(\S+)')
    LNRE = re.compile(r'^(\s*(\| +)*)\+-(\S+)')

    def __init__(self, inp=sys.stdin, altfd=NullFD()):
        self.input = inp
        self.top_level = []
        self.altfd = altfd

    def process(self):
        current_stack = []
        for line in self.input:
            l1m = self.L1RE.search(line)
            lNm = self.LNRE.search(line)
            if l1m:
                node = mk_node(l1m.group(1))
                current_stack = [node]
                self.top_level.append(node)
            elif lNm:
                level = len(lNm.group(1)) / 2
                level += 1
                node = mk_node(lNm.group(3))
                if len(current_stack) > (level - 1):
                    current_stack = current_stack[:(level - 1)]
                current_stack.append(node)
                current_stack[level - 2].children.add(node)
            else:
                self.altfd.write(line)


##########################################################################
# Data structure
##########################################################################

def mk_node(name):
    global NODE_HASH
    if name in NODE_HASH:
        return NODE_HASH[name]
    else:
        node = Node(name)
        NODE_HASH[name] = node
        return node


NODE_HASH = {}


class Node(object):
    """
    The Node data structure creates a simple ad hoc tree.
    Using mk_node, above limits the Nodes to be unique by name.
    (I think this could be done with some __new__ magic, but
    I'd have to look it up).
    """

    def __init__(self, name, children=None):
        self.name = name
        self.ignore = False
        if children == None:
            self.children = sets.Set()
        else:
            self.children = children

    def __eq__(self, other):
        return self.name == other.name

    def __hash__(self):
        return hash(self.name)

    def __repr__(self):
        return '%s:%d' % (self.name, len(self.children))


##########################################################################
# Script
##########################################################################

def run(args):
    """
    Parse the command-line(-eque) args, and run the program.
    """
    import optparse
    parser = optparse.OptionParser(usage=cmd_line_usage)
    parser.add_option('-o', '--outfile', default='-')
    parser.add_option('-i', '--infile',  default='-')
    parser.add_option(
        '--altfile', default='-',
        help='The file to put things not matched as part of the tree, default is stdout.',
    )
    parser.add_option(
        '--save', action='store_true',
        help='Save the dot file and invoke the dot command, save the resulting file to OUTFILE',
    )
    parser.add_option(
        '--format', default='pdf',
        help='Format to output when using the --save option, default is pdf. For legal values, see the -T option in dot.',
    )
    parser.add_option(
        '--ignore', default=[], action='append',
        help='ignore a file pattern (python re)',
    )
    parser.add_option(
        '--graph-opt', default=[], action='append',
        help='Dot graph option, as a key=value pair.',
    )
    parser.add_option(
        '--node-opt',  default=[], action='append',
        help='Dot node option, as a key=value pair.',
    )
    parser.add_option(
        '--edge-opt',  default=[], action='append',
        help='Dot edge option, as a key=value pair.',
    )

    (opts, args) = parser.parse_args(args)
    infd = None
    if opts.infile == '-':
        infd = sys.stdin
    else:
        infd = file(opts.infile, 'r')

    altfd = None
    if opts.altfile == '-':
        altfd = sys.stdout
    else:
        altfd = file(opts.altfile, 'w')

    # process dot options
    graph_attrs = {}
    for opt in opts.graph_opt:
        k, v = opt.split('=')
        graph_attrs[k] = v
    node_attrs = {}
    for opt in opts.node_opt:
        k, v = opt.split('=')
        node_attrs[k] = v
    edge_attrs = {}
    for opt in opts.edge_opt:
        k, v = opt.split('=')
        edge_attrs[k] = v

    sfp = SConsForestParser(infd, altfd=altfd)
    sfp.process()
    db = DotBuilder(
        sfp.top_level,
        dot_fname=opts.outfile,
        dot_format=opts.format,
        ignore_list=opts.ignore,
        graph_attrs=graph_attrs,
        node_attrs=node_attrs,
        edge_attrs=edge_attrs,
    )
    if opts.save:
        db.save_graph()
    else:
        outfd = None
        if opts.outfile == '-':
            outfd = sys.stdout
        else:
            outfd = file(opts.outfile, 'w')
        db.fd = outfd
        db.print_graph()


if __name__ == '__main__':
    run(sys.argv[1:])
