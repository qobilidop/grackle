#include "chemistry_data.h"
#include "code_units.h"
#include "phys_constants.h"

chemistry_data set_default_chemistry_parameters();

int initialize_chemistry_data(chemistry_data &my_chemistry,
                              code_units &my_units, float a_value);

int solve_chemistry(chemistry_data &my_chemistry,
		    code_units &my_units,
		    float a_value, float dt_value,
		    int grid_rank, int *grid_dimension,
		    int *grid_start, int *grid_end,
		    float *density, float *internal_energy,
		    float *x_velocity, float *y_velocity, float  *z_velocity,
		    float *HI_density, float *HII_density, float *HM_density,
		    float *HeI_density, float *HeII_density, float *HeIII_density,
		    float *H2I_density, float *H2II_density,
		    float *DI_density, float *DII_density, float *HD_density,
		    float *e_density, float *metal_density);
