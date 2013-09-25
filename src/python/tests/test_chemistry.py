import numpy as np
from numpy.testing import assert_array_equal, assert_almost_equal, \
    assert_approx_equal, assert_array_almost_equal, assert_equal, \
    assert_array_less, assert_string_equal, assert_array_almost_equal_nulp,\
    assert_allclose, assert_raises

def assert_rel_equal(a1, a2, decimals, err_msg='', verbose=True):
    if isinstance(a1, np.ndarray):
        assert(a1.size == a2.size)
        # Mask out NaNs
        a1[np.isnan(a1)] = 1.0
        a2[np.isnan(a2)] = 1.0
    elif np.any(np.isnan(a1)) and np.any(np.isnan(a2)):
        return True
    return assert_almost_equal(np.array(a1)/np.array(a2), 1.0, 
                               decimals, err_msg=err_msg,
                               verbose=verbose)

from pygrackle.grackle_wrapper import *
from pygrackle.fluid_container import FluidContainer

from utilities.api import \
     setup_fluid_container, \
     set_cosmology_units, \
     get_cooling_units

from utilities.physical_constants import \
     mass_hydrogen_cgs, \
     sec_per_Gyr, \
     cm_per_mpc

def random_logscale(log_min, log_max, size=1):
    log_val = (log_max - log_min) * np.random.random(size) + log_min
    return np.power(10, log_val)

def test_proper_comoving_units():
    "Make sure proper and comoving units systems give the same answer."

    for current_redshift in [0., 1., 3., 6., 9.]:

        # comoving units
        chem_c = chemistry_data()
        chem_c.use_chemistry = 1
        chem_c.with_radiative_cooling = 0
        chem_c.primordial_chemistry = 1
        chem_c.metal_cooling = 1
        chem_c.UVbackground = 1
        chem_c.include_metal_heating = 1
        chem_c.grackle_data_file = "../../../input/CloudyData_UVB=HM2012.h5"
        set_cosmology_units(chem_c, 
                            current_redshift=current_redshift,
                            initial_redshift=99.)
        fc_c = setup_fluid_container(chem_c, current_redshift=current_redshift,
                                     converge=True)
        calculate_temperature(fc_c)
        a_c = 1.0 / (1.0 + current_redshift) / chem_c.a_units
        calculate_cooling_time(fc_c, a_c)
        t_sort_c = np.argsort(fc_c["temperature"])
        t_cool_c = fc_c["cooling_time"][t_sort_c] * chem_c.time_units

        # proper units
        chem_p = chemistry_data()
        chem_p.use_chemistry = 1
        chem_p.with_radiative_cooling = 0
        chem_p.primordial_chemistry = 1
        chem_p.metal_cooling = 1
        chem_p.UVbackground = 1
        chem_p.include_metal_heating = 1
        chem_p.grackle_data_file = "../../../input/CloudyData_UVB=HM2012.h5"
        chem_p.comoving_coordinates = 0
        chem_p.a_units = 1.0
        # Set the proper units to be of similar magnitude to the 
        # comoving system to help the solver be more efficient.
        chem_p.density_units = random_logscale(-2, 2) * \
          chem_c.density_units / (1 + current_redshift)**3
        chem_p.length_units = random_logscale(-2, 2) * \
          chem_c.length_units * (1 + current_redshift)
        chem_p.time_units = random_logscale(-2, 2) * \
          chem_c.time_units
        chem_p.velocity_units = chem_p.length_units / chem_p.time_units
        fc_p = setup_fluid_container(chem_p, current_redshift=current_redshift,
                                     converge=True)
        calculate_temperature(fc_p)
        a_p = 1.0 / (1.0 + current_redshift) / chem_p.a_units
        calculate_cooling_time(fc_p, a_p)      
        t_sort_p = np.argsort(fc_p["temperature"])
        t_cool_p = fc_p["cooling_time"][t_sort_p] * chem_p.time_units

        yield assert_rel_equal, t_cool_p, t_cool_c, 4, \
          "Proper and comoving cooling times disagree for z = %f with min/max = %f/%f." % \
          (current_redshift, (t_cool_p / t_cool_c).min(), (t_cool_p / t_cool_c).max())

def test_proper_units():
    "Make sure two different proper units systems give the same answer."

    for current_redshift in [0., 1., 3.]:

        # proper units
        chem_1 = chemistry_data()
        chem_1.use_chemistry = 1
        chem_1.with_radiative_cooling = 0
        chem_1.primordial_chemistry = 1
        chem_1.metal_cooling = 1
        chem_1.UVbackground = 1
        chem_1.include_metal_heating = 1
        chem_1.grackle_data_file = "../../../input/CloudyData_UVB=HM2012.h5"
        chem_1.comoving_coordinates = 0
        chem_1.a_units = 1.0
        chem_1.density_units = random_logscale(-30, -10)
        chem_1.length_units = random_logscale(0, 2)
        chem_1.time_units = random_logscale(0, 2)
        chem_1.velocity_units = chem_1.length_units / chem_1.time_units
        fc_1 = setup_fluid_container(chem_1, current_redshift=current_redshift,
                                     converge=False)
        calculate_temperature(fc_1)
        a_1 = 1.0 / (1.0 + current_redshift) / chem_1.a_units
        calculate_cooling_time(fc_1, a_1)      
        t_sort_1 = np.argsort(fc_1["temperature"])
        t_cool_1 = fc_1["cooling_time"][t_sort_1] * chem_1.time_units

        # proper units
        chem_2 = chemistry_data()
        chem_2.use_chemistry = 1
        chem_2.with_radiative_cooling = 0
        chem_2.primordial_chemistry = 1
        chem_2.metal_cooling = 1
        chem_2.UVbackground = 1
        chem_2.include_metal_heating = 1
        chem_2.grackle_data_file = "../../../input/CloudyData_UVB=HM2012.h5"
        chem_2.comoving_coordinates = 0
        chem_2.a_units = 1.0
        chem_2.density_units = random_logscale(-30, -10)
        chem_2.length_units = random_logscale(0, 2)
        chem_2.time_units = random_logscale(0, 2)
        chem_2.velocity_units = chem_2.length_units / chem_2.time_units
        fc_2 = setup_fluid_container(chem_2, current_redshift=current_redshift,
                                     converge=False)
        calculate_temperature(fc_2)
        a_2 = 1.0 / (1.0 + current_redshift) / chem_2.a_units
        calculate_cooling_time(fc_2, a_2)      
        t_sort_2 = np.argsort(fc_2["temperature"])
        t_cool_2 = fc_2["cooling_time"][t_sort_2] * chem_2.time_units

        # comoving units

        yield assert_rel_equal, t_cool_1, t_cool_2, 6, \
          "Proper and comoving cooling times disagree for z = %f with min/max = %f/%f." % \
          (current_redshift, (t_cool_1/t_cool_2).min(), (t_cool_1/t_cool_2).max())

