#define CLOUDY_COOLING_MAX_DIMENSION 5

struct chemistry_data
{

  // adiabatic index
  gr_float Gamma;

  /****************************************
   *** chemistry and cooling parameters ***
   ****************************************/

  gr_int use_chemistry;
  gr_int primordial_chemistry; // 1) HI, HII, HeI, HeII, HeIII, e
                            // 2) + H2, H2I+, H-
                            // 3) + D, D+, HD
  gr_int metal_cooling;        // 0) off, 1) on using Cloudy tables
  gr_int h2_on_dust;  // should be left off for now

  // Use a CMB temperature floor.
  gr_int cmb_temperature_floor;

  // Flag to control whether or not to include heating from Cloudy.
  gr_int include_metal_heating;

  // Cooling grid file.
  char *cloudy_table_file;

  /* additional H2 chemistry parameters
     best left unchanged. */
  
  gr_int three_body_rate;
  gr_int cie_cooling;
  gr_int h2_optical_depth_approximation;

  /* photo-electric heating from irradiated dust */

  gr_int photoelectric_heating;
  gr_float photoelectric_heating_rate; // in CGS

  /***************************************
   *** radiation background parameters ***
   ***************************************/

  gr_int RadiationFieldType;
  gr_int AdjustUVBackground; 
  gr_int AdjustUVBackgroundHighRedshift; 
  gr_float SetUVBAmplitude;
  gr_float SetHeIIHeatingScale;
  gr_int RadiationFieldLevelRecompute;
  gr_int RadiationXRaySecondaryIon;
  gr_int RadiationXRayComptonHeating;
  gr_int TabulatedLWBackground;
  gr_float RadiationFieldRedshift;
  gr_float f3;
  gr_float f0to3;
  gr_float RadiationRedshiftOn;
  gr_float RadiationRedshiftOff;
  gr_float RadiationRedshiftFullOn;
  gr_float RadiationRedshiftDropOff;

  /**************************************
   *** primordial chemistry rate data ***
   **************************************/

  gr_int NumberOfTemperatureBins;   
  gr_int CaseBRecombination;
  gr_float TemperatureStart;        // range of temperature in K
  gr_float TemperatureEnd;

  /* 6 species rates */

  gr_float *k1;
  gr_float *k2;
  gr_float *k3;
  gr_float *k4;
  gr_float *k5;
  gr_float *k6;

  /* 9 species rates (including H2) */

  gr_float *k7;
  gr_float *k8;
  gr_float *k9;
  gr_float *k10;
  gr_float *k11;
  gr_float *k12;
  gr_float *k13;
  gr_float *k14;
  gr_float *k15;
  gr_float *k16;
  gr_float *k17;
  gr_float *k18;
  gr_float *k19;
  gr_float *k20;  /* currently not used */
  gr_float *k21;  /* currently not used */
  gr_float *k22;  /* 3-body H2 formation */
  gr_float *k23;  /* H2-H2 dissociation */

  gr_float *k13dd;  /* density dependent version of k13 (collisional H2
                    dissociation); actually 7 functions instead of 1. */

  /* Radiative rates for 6-species (for external field). */

  gr_float k24;
  gr_float k25;
  gr_float k26;

  /* Radiative rates for 9-species (for external field). */

  gr_float k27;
  gr_float k28;
  gr_float k29;
  gr_float k30;
  gr_float k31;

  /* 12 species rates (with Deuterium). */

  gr_float *k50;
  gr_float *k51;
  gr_float *k52;
  gr_float *k53;
  gr_float *k54;
  gr_float *k55;
  gr_float *k56;

  /* H2 formation on dust. */

  gr_int NumberOfDustTemperatureBins;   
  gr_float DustTemperatureStart;        // range of temperature in K
  gr_float DustTemperatureEnd;
  gr_float *h2dust;                     // function of Tgas and Tdust

  /* Chemical heating from H2 formation. */
  /* numerator and denominator of Eq 23 of Omukai ea. 2000. */

  gr_float *n_cr_n;
  gr_float *n_cr_d1;
  gr_float *n_cr_d2;

  /********************
   *** cooling data ***
   ********************/

  gr_int ih2co;                     // flag for H2 cooling (0-off/1-on)
  gr_int ipiht;                     // flag for photoionization cooling

  gr_float HydrogenFractionByMass;
  gr_float DeuteriumToHydrogenRatio;
  gr_float SolarMetalFractionByMass;

  /* 6 species rates */

  gr_float *ceHI;                   // collisional excitation rates
  gr_float *ceHeI;
  gr_float *ceHeII;
  gr_float *ciHI;                   // collisional ionization
  gr_float *ciHeI;
  gr_float *ciHeIS;
  gr_float *ciHeII;
  gr_float *reHII;                  // recombination
  gr_float *reHeII1;
  gr_float *reHeII2;
  gr_float *reHeIII;
  gr_float *brem;                   // free-free (Bremsstrahlung)
  gr_float comp;                    // Compton cooling
  gr_float comp_xray;               // X-ray compton heating coefficient
  gr_float temp_xray;               // X-ray compton heating temperature (K)
  gr_float gammah;                  // Photoelectric heating (code units)

  /* radiative rates (external field). */

  gr_float piHI;                    // photo-ionization cooling
  gr_float piHeI;                   //    (no temperature dependance)
  gr_float piHeII;

  /* 9 species rates (including H2) 
       The first five are for the Lepp & Shull rates.
       The next two are for the (better) Galli & Palla 1999 rates. 
       The selection is controlled by a flag in cool1d_multi.src. */

  gr_float *hyd01k;
  gr_float *h2k01;
  gr_float *vibh;
  gr_float *roth;
  gr_float *rotl;

  gr_float *GP99LowDensityLimit;
  gr_float *GP99HighDensityLimit;

  /* Revised H2 cooling rates from Glover & Abel 2008 */
  gr_float *GAHI;
  gr_float *GAH2;
  gr_float *GAHe;
  gr_float *GAHp;
  gr_float *GAel;

  /* 12 species rates (including HD) */

  gr_float *HDlte;
  gr_float *HDlow;
  gr_float *HDcool;

  /* CIE cooling */
  gr_float *cieco;

  /* Gas/grain energy transfer. */
  gr_float *gas_grain;

  /***************************
   *** cloudy cooling data ***
   ***************************/

  // Factor to account for extra electrons from metals.
  /* 
     f = SUM { A_i * i }, for i = 3 to N.
     N = Atomic number of heaviest element in cooling model.
     For solar abundance patters and N = 30 (Zn), f = 9.153959e-3.
   */
  gr_float CloudyElectronFractionFactor;

  // Rank of Cloudy dataset.
  gr_int CloudyCoolingGridRank;

  // Dimension of Cloudy dataset.
  gr_int *CloudyCoolingGridDimension;

  // Dataset parameter values.
  //  gr_float *CloudyCoolingGridParameters[CLOUDY_COOLING_MAX_DIMENSION];
  gr_float **CloudyCoolingGridParameters;

  // Heating values
  gr_float *CloudyHeating;

  // Cooling values
  gr_float *CloudyCooling;

  // Length of 1D flattened Cloudy data
  gr_int CloudyDataSize;
};
