from ah_system import ah_model, ah2_model
from set_params import set_params
from collections import OrderedDict
import time
import itertools as it
import numpy as np

debug = False
test_key = 'meinhardt5_3'
full_run = True
size = 500
time_steps = 700

param_ranges, reaction_f, model_type = set_params(test_key)

# in theory this generator will take a list of lists of possible
# parameter values and yield every possible combination of params.
# in theory.
# param_list is a list of tuples and param_set is an OrderedDict.
# note that param_list does not need to be in the same order as
# param_set.
def product(param_list, param_set):
    for val in param_list[0][1]:
        # set the value of the first parameter
        param_set[param_list[0][0]] = val
        # if this isn't the last parameter, recurse
        if len(param_list) is not 1:
            for prod in product(param_list[1:], param_set):
                yield prod
        # else we have a complete parameter set and can yield it
        else:
            yield param_set

def set_steps(diffs):
    # an attempt at automatically setting the correct dx and dt
    # depending on the diffusion rates.
    # if we fix dx = 1 then dt < 1/2*diff
#    dx = 1
#    diff = max(diffa, diffi) if max(diffa, diffi) > 0 else 1
#    stable = 0.9 * (1/(2*diff))
#    dt = stable if stable < 10 else 10

    # alternatively, if we fix dx = dt then dt > 2 * diff
    diff = max(diffs) if max(diffs) > 0 else 1
    stable = 1.1 * 2 * diff
    dx = stable
    dt = stable
    return dx, dt

runs = 0

# list all parameter combinations
#param_sets = list(it.product(*param_ranges.values()))
# this didn't work: python replied 'Killed', wasn't beefy enough
# going to try using many loops instead.
# no, many loops is ugly. recursion?
# recursive generator works nicely.

empty_p = OrderedDict(zip(param_ranges.keys(),[0]*len(param_ranges.keys())))

start = time.time()

for params in product(list(param_ranges.items()), empty_p):
    try:
        runs = runs + 1
        if model_type is 'basic':
            if ('dx' or 'dt') not in param_ranges:
                params['dx'], params['dt'] = set_steps(params['diffa'],params['diffi'])
            ah_model(reaction_f, params, size, time_steps, debug)
        elif model_type is 'duali':
            if ('dx' or 'dt') not in param_ranges:
                params['dx'], params['dt'] = set_steps([params['diffa'],params['diffi'],params['diffi2']])
            ah2_model(reaction_f, params, size, time_steps, debug)
        else:
            raise ValueError("Invalid model_type")
    except ValueError as e:
        runs = runs - 1
        print("ERROR: ", e)

end = time.time()
print('number of runs: ', runs)
print('time taken: ', end-start)
print('time per run: ', (end-start)/runs)

#params = OrderedDict([
#    ('innita',2),
#    ('inniti',2),
#    ('dt',0.5),
#    ('dx',0.4),
#    ('diffa',0.1),
#    ('diffi',0.0),
#    ('proda',6),
#    ('prodi',4),
#    ('rema',0.02),
#    ('remi',0.0075),
#    ('sdens',0.015),
#    ('rho_0',0.02),
#    ('rho_var',0.14),
#    ('sat',0.0004),
#    ('mu',0.05),
#    ('nu',0.03)
#])
