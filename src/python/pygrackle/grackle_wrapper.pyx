from grackle_defs cimport *
import numpy as np
cimport numpy as np

cdef class chemistry_data:
    cdef c_chemistry_data data
    cdef c_code_units units

    def __cinit__(self):
        self.data = set_default_chemistry_parameters()

    def initialize(self, a_value):
        return initialize_chemistry_data(self.data, self.units, a_value)

    def update_UVbackground(self, a_value):
        update_UVbackground_rates(self.data, self.units, a_value)

    property Gamma:
        def __get__(self):
            return self.data.Gamma
        def __set__(self, val):
            self.data.Gamma = val

    property use_chemistry:
        def __get__(self):
            return self.data.use_chemistry
        def __set__(self, val):
            self.data.use_chemistry = val

    property with_radiative_cooling:
        def __get__(self):
            return self.data.with_radiative_cooling
        def __set__(self, val):
            self.data.with_radiative_cooling = val

    property primordial_chemistry:
        def __get__(self):
            return self.data.primordial_chemistry
        def __set__(self, val):
            self.data.primordial_chemistry = val

    property metal_cooling:
        def __get__(self):
            return self.data.metal_cooling
        def __set__(self, val):
            self.data.metal_cooling = val

    property h2_on_dust:
        def __get__(self):
            return self.data.h2_on_dust
        def __set__(self, val):
            self.data.h2_on_dust = val

    property cmb_temperature_floor:
        def __get__(self):
            return self.data.cmb_temperature_floor
        def __set__(self, val):
            self.data.cmb_temperature_floor = val

    property three_body_rate:
        def __get__(self):
            return self.data.three_body_rate
        def __set__(self, val):
            self.data.three_body_rate = val

    property cie_cooling:
        def __get__(self):
            return self.data.cie_cooling
        def __set__(self, val):
            self.data.cie_cooling = val

    property h2_optical_depth_approximation:
        def __get__(self):
            return self.data.h2_optical_depth_approximation
        def __set__(self, val):
            self.data.h2_optical_depth_approximation = val

    property photoelectric_heating:
        def __get__(self):
            return self.data.photoelectric_heating
        def __set__(self, val):
            self.data.photoelectric_heating = val

    property grackle_data_file:
        def __get__(self):
            return self.data.grackle_data_file
        def __set__(self, val):
            self.data.grackle_data_file = val

    property UVbackground:
        def __get__(self):
            return self.data.UVbackground
        def __set__(self, val):
            self.data.UVbackground = val

    property comoving_coordinates:
        def __get__(self):
            return self.units.comoving_coordinates
        def __set__(self, val):
            self.units.comoving_coordinates = val

    property density_units:
        def __get__(self):
            return self.units.density_units
        def __set__(self, val):
            self.units.density_units = val

    property length_units:
        def __get__(self):
            return self.units.length_units
        def __set__(self, val):
            self.units.length_units = val

    property time_units:
        def __get__(self):
            return self.units.time_units
        def __set__(self, val):
            self.units.time_units = val

    property velocity_units:
        def __get__(self):
            return self.units.velocity_units
        def __set__(self, val):
            self.units.velocity_units = val

    property a_units:
        def __get__(self):
            return self.units.a_units
        def __set__(self, val):
            self.units.a_units = val

cdef gr_float* get_field(fc, name):
    cdef np.ndarray rv = fc.get(name, None)
    if rv is None:
        return NULL
    else:
        return <gr_float *> rv.data

def solve_chemistry(fc, my_a, my_dt):
    cdef gr_int grid_rank = 1
    cdef gr_int grid_dimension
    grid_dimension = fc["density"].shape[0]

    cdef np.ndarray ref_gs, ref_ge
    ref_gs = np.zeros(3, dtype="int64")
    ref_ge = np.zeros(3, dtype="int64")
    ref_ge[0] = grid_dimension - 1
    cdef gr_int *grid_start, *grid_end
    grid_start = <gr_int *> ref_gs.data
    grid_end = <gr_int *> ref_ge.data

    cdef gr_float a_value = <gr_float> my_a
    cdef gr_float dt_value = <gr_float> my_dt

    cdef chemistry_data chem_data = fc.chemistry_data
    cdef c_chemistry_data my_chemistry = chem_data.data
    cdef c_code_units my_units = chem_data.units
    cdef gr_float *density = get_field(fc, "density")
    cdef gr_float *internal_energy = get_field(fc, "energy")
    cdef gr_float *x_velocity = get_field(fc, "x-velocity")
    cdef gr_float *y_velocity = get_field(fc, "y-velocity")
    cdef gr_float *z_velocity = get_field(fc, "z-velocity")
    cdef gr_float *HI_density = get_field(fc, "HI")
    cdef gr_float *HII_density = get_field(fc, "HII")
    cdef gr_float *HM_density = get_field(fc, "HM")
    cdef gr_float *HeI_density = get_field(fc, "HeI")
    cdef gr_float *HeII_density = get_field(fc, "HeII")
    cdef gr_float *HeIII_density = get_field(fc, "HeIII")
    cdef gr_float *H2I_density = get_field(fc, "H2I")
    cdef gr_float *H2II_density = get_field(fc, "H2II")
    cdef gr_float *DI_density = get_field(fc, "DI")
    cdef gr_float *DII_density = get_field(fc, "DII")
    cdef gr_float *HDI_density = get_field(fc, "HDI")
    cdef gr_float *e_density = get_field(fc, "de")
    cdef gr_float *metal_density = get_field(fc, "metal")

    c_solve_chemistry (
                my_chemistry,
                my_units,
                a_value,
                dt_value,
                grid_rank,
                &grid_dimension,
                grid_start,
                grid_end,
                density,
                internal_energy,
                x_velocity,
                y_velocity,
                z_velocity,
                HI_density,
                HII_density,
                HM_density,
                HeI_density,
                HeII_density,
                HeIII_density,
                H2I_density,
                H2II_density,
                DI_density,
                DII_density,
                HDI_density,
                e_density,
                metal_density)
    
def calculate_cooling_time(fc, my_a):
    cdef gr_int grid_rank = 1
    cdef gr_int grid_dimension
    grid_dimension = fc["density"].shape[0]

    cdef np.ndarray ref_gs, ref_ge
    ref_gs = np.zeros(3, dtype="int64")
    ref_ge = np.zeros(3, dtype="int64")
    ref_ge[0] = grid_dimension -1 
    cdef gr_int *grid_start, *grid_end
    grid_start = <gr_int *> ref_gs.data
    grid_end = <gr_int *> ref_ge.data

    cdef gr_float a_value = <gr_float> my_a

    cdef chemistry_data chem_data = fc.chemistry_data
    cdef c_chemistry_data my_chemistry = chem_data.data
    cdef c_code_units my_units = chem_data.units
    cdef gr_float *density = get_field(fc, "density")
    cdef gr_float *internal_energy = get_field(fc, "energy")
    cdef gr_float *x_velocity = get_field(fc, "x-velocity")
    cdef gr_float *y_velocity = get_field(fc, "y-velocity")
    cdef gr_float *z_velocity = get_field(fc, "z-velocity")
    cdef gr_float *HI_density = get_field(fc, "HI")
    cdef gr_float *HII_density = get_field(fc, "HII")
    cdef gr_float *HM_density = get_field(fc, "HM")
    cdef gr_float *HeI_density = get_field(fc, "HeI")
    cdef gr_float *HeII_density = get_field(fc, "HeII")
    cdef gr_float *HeIII_density = get_field(fc, "HeIII")
    cdef gr_float *H2I_density = get_field(fc, "H2I")
    cdef gr_float *H2II_density = get_field(fc, "H2II")
    cdef gr_float *DI_density = get_field(fc, "DI")
    cdef gr_float *DII_density = get_field(fc, "DII")
    cdef gr_float *HDI_density = get_field(fc, "HDI")
    cdef gr_float *e_density = get_field(fc, "de")
    cdef gr_float *metal_density = get_field(fc, "metal")
    cdef gr_float *cooling_time = get_field(fc, "cooling_time")
    
    c_calculate_cooling_time (
                my_chemistry,
                my_units,
                a_value,
                grid_rank,
                &grid_dimension,
                grid_start,
                grid_end,
                density,
                internal_energy,
                x_velocity,
                y_velocity,
                z_velocity,
                HI_density,
                HII_density,
                HM_density,
                HeI_density,
                HeII_density,
                HeIII_density,
                H2I_density,
                H2II_density,
                DI_density,
                DII_density,
                HDI_density,
                e_density,
                metal_density,
                cooling_time)
    
def calculate_gamma(fc):
    cdef gr_int grid_rank = 1
    cdef gr_int grid_dimension
    grid_dimension = fc["density"].shape[0]
    cdef chemistry_data chem_data = fc.chemistry_data
    cdef c_chemistry_data my_chemistry = chem_data.data
    cdef c_code_units my_units = chem_data.units
    cdef gr_float *density = get_field(fc, "density")
    cdef gr_float *internal_energy = get_field(fc, "energy")
    cdef gr_float *HI_density = get_field(fc, "HI")
    cdef gr_float *HII_density = get_field(fc, "HII")
    cdef gr_float *HM_density = get_field(fc, "HM")
    cdef gr_float *HeI_density = get_field(fc, "HeI")
    cdef gr_float *HeII_density = get_field(fc, "HeII")
    cdef gr_float *HeIII_density = get_field(fc, "HeIII")
    cdef gr_float *H2I_density = get_field(fc, "H2I")
    cdef gr_float *H2II_density = get_field(fc, "H2II")
    cdef gr_float *DI_density = get_field(fc, "DI")
    cdef gr_float *DII_density = get_field(fc, "DII")
    cdef gr_float *HDI_density = get_field(fc, "HDI")
    cdef gr_float *e_density = get_field(fc, "de")
    cdef gr_float *metal_density = get_field(fc, "metal")
    cdef gr_float *gamma = get_field(fc, "gamma")
    
    c_calculate_gamma (
                my_chemistry,
                my_units,
                grid_rank,
                &grid_dimension,
                density,
                internal_energy,
                HI_density,
                HII_density,
                HM_density,
                HeI_density,
                HeII_density,
                HeIII_density,
                H2I_density,
                H2II_density,
                DI_density,
                DII_density,
                HDI_density,
                e_density,
                metal_density,
                gamma)
    
def calculate_pressure(fc):
    cdef gr_int grid_rank = 1
    cdef gr_int grid_dimension
    grid_dimension = fc["density"].shape[0]
    cdef chemistry_data chem_data = fc.chemistry_data
    cdef c_chemistry_data my_chemistry = chem_data.data
    cdef c_code_units my_units = chem_data.units
    cdef gr_float *density = get_field(fc, "density")
    cdef gr_float *internal_energy = get_field(fc, "energy")
    cdef gr_float *HI_density = get_field(fc, "HI")
    cdef gr_float *HII_density = get_field(fc, "HII")
    cdef gr_float *HM_density = get_field(fc, "HM")
    cdef gr_float *HeI_density = get_field(fc, "HeI")
    cdef gr_float *HeII_density = get_field(fc, "HeII")
    cdef gr_float *HeIII_density = get_field(fc, "HeIII")
    cdef gr_float *H2I_density = get_field(fc, "H2I")
    cdef gr_float *H2II_density = get_field(fc, "H2II")
    cdef gr_float *DI_density = get_field(fc, "DI")
    cdef gr_float *DII_density = get_field(fc, "DII")
    cdef gr_float *HDI_density = get_field(fc, "HDI")
    cdef gr_float *e_density = get_field(fc, "de")
    cdef gr_float *metal_density = get_field(fc, "metal")
    cdef gr_float *pressure = get_field(fc, "pressure")
    
    c_calculate_pressure (
                my_chemistry,
                my_units,
                grid_rank,
                &grid_dimension,
                density,
                internal_energy,
                HI_density,
                HII_density,
                HM_density,
                HeI_density,
                HeII_density,
                HeIII_density,
                H2I_density,
                H2II_density,
                DI_density,
                DII_density,
                HDI_density,
                e_density,
                metal_density,
                pressure)

def calculate_temperature(fc):
    cdef gr_int grid_rank = 1
    cdef gr_int grid_dimension
    grid_dimension = fc["density"].shape[0]
    cdef chemistry_data chem_data = fc.chemistry_data
    cdef c_chemistry_data my_chemistry = chem_data.data
    cdef c_code_units my_units = chem_data.units
    cdef gr_float *density = get_field(fc, "density")
    cdef gr_float *internal_energy = get_field(fc, "energy")
    cdef gr_float *HI_density = get_field(fc, "HI")
    cdef gr_float *HII_density = get_field(fc, "HII")
    cdef gr_float *HM_density = get_field(fc, "HM")
    cdef gr_float *HeI_density = get_field(fc, "HeI")
    cdef gr_float *HeII_density = get_field(fc, "HeII")
    cdef gr_float *HeIII_density = get_field(fc, "HeIII")
    cdef gr_float *H2I_density = get_field(fc, "H2I")
    cdef gr_float *H2II_density = get_field(fc, "H2II")
    cdef gr_float *DI_density = get_field(fc, "DI")
    cdef gr_float *DII_density = get_field(fc, "DII")
    cdef gr_float *HDI_density = get_field(fc, "HDI")
    cdef gr_float *e_density = get_field(fc, "de")
    cdef gr_float *metal_density = get_field(fc, "metal")
    cdef gr_float *temperature = get_field(fc, "temperature")

    c_calculate_temperature(
                my_chemistry,
                my_units,
                grid_rank,
                &grid_dimension,
                density,
                internal_energy,
                HI_density,
                HII_density,
                HM_density,
                HeI_density,
                HeII_density,
                HeIII_density,
                H2I_density,
                H2II_density,
                DI_density,
                DII_density,
                HDI_density,
                e_density,
                metal_density,
                temperature)
