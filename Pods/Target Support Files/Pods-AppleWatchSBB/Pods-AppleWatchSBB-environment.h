
// To check if a library is compiled with CocoaPods you
// can use the `COCOAPODS` macro definition which is
// defined in the xcconfigs so it is available in
// headers also when they are imported in the client
// project.


// SCLAlertView-Objective-C
#define COCOAPODS_POD_AVAILABLE_SCLAlertView_Objective_C
#define COCOAPODS_VERSION_MAJOR_SCLAlertView_Objective_C 0
#define COCOAPODS_VERSION_MINOR_SCLAlertView_Objective_C 7
#define COCOAPODS_VERSION_PATCH_SCLAlertView_Objective_C 0

// UICocoapodsLib
#define COCOAPODS_POD_AVAILABLE_UICocoapodsLib
#define COCOAPODS_VERSION_MAJOR_UICocoapodsLib 0
#define COCOAPODS_VERSION_MINOR_UICocoapodsLib 1
#define COCOAPODS_VERSION_PATCH_UICocoapodsLib 0

// Debug build configuration
#ifdef DEBUG

  // SimulatorStatusMagic
  #define COCOAPODS_POD_AVAILABLE_SimulatorStatusMagic
  #define COCOAPODS_VERSION_MAJOR_SimulatorStatusMagic 1
  #define COCOAPODS_VERSION_MINOR_SimulatorStatusMagic 6
  #define COCOAPODS_VERSION_PATCH_SimulatorStatusMagic 1

#endif
