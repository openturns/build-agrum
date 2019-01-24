#!/usr/bin/env python

from __future__ import print_function
import pyAgrum as gum

# https://gitlab.com/agrumery/aGrUM/issues/15
bn = gum.fastBN('a->b->d;a->c->d->e;f->b')
ie = gum.LazyPropagation(bn)
ie.makeInference()
print(ie.posterior('d'))

# https://gitlab.com/agrumery/aGrUM/issues/24
bn = gum.fastBN('a->b')
jointe = gum.Potential().fillWith(1)
#for i in range(2):
    #jointe *= bn.cpt(i)
print(jointe)
