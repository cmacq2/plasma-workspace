add_definitions(-DTRANSLATION_DOMAIN=\"plasma_applet_org.kde.plasma.digitalclock\")

set(digitalclockplugin_SRCS
    timezonemodel.cpp
    timezonesi18n.cpp
    digitalclockplugin.cpp
    )

add_library(digitalclockplugin SHARED ${digitalclockplugin_SRCS})
target_link_libraries(digitalclockplugin Qt5::Core
                                          Qt5::Qml
                                          KF5::CoreAddons
                                          KF5::I18n)

install(TARGETS digitalclockplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/digitalclock)

install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/digitalclock)
