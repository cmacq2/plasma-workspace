set (ion_bbcukmet_SRCS ion_bbcukmet.cpp)
add_library(ion_bbcukmet MODULE ${ion_bbcukmet_SRCS})
target_link_libraries (ion_bbcukmet KF5::Solid weather_ion)

install (FILES ion-bbcukmet.desktop DESTINATION ${KDE_INSTALL_KSERVICES5DIR})

install (TARGETS ion_bbcukmet DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/dataengine)

