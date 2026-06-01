cmake_minimum_required(VERSION 3.21)

project(RGCS VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Core Quick QuickControls2 Sql Positioning Location Multimedia SerialPort Network)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(rgcs
    src/main.cpp
    src/core/AppController.cpp
    src/core/AuthManager.cpp
    src/core/PermissionManager.cpp
    src/core/AuditLogger.cpp
    src/mavlink/MavlinkConnectionManager.cpp
    src/mavlink/TelemetryManager.cpp
    src/mavlink/CommandManager.cpp
    src/mission/MissionManager.cpp
    src/settings/AppSettingsManager.cpp
    src/util/CoordinateConverter.cpp
)

qt_add_qml_module(rgcs
    URI RGCS
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/components/AppShell.qml
        qml/components/Sidebar.qml
        qml/components/SidebarButton.qml
        qml/components/TopStatusBar.qml
        qml/components/StatusCard.qml
        qml/components/TelemetryCard.qml
        qml/components/TelemetryGroup.qml
        qml/components/ActionButton.qml
        qml/components/ConfirmDialog.qml
        qml/components/SlideToConfirm.qml
        qml/components/MapControlButton.qml
        qml/components/MissionWaypointEditor.qml
        qml/components/ParameterEditor.qml
        qml/components/CalibrationPanel.qml
        qml/components/DiagnosticGauge.qml
        qml/components/VibrationAxisView.qml
        qml/screens/LoginScreen.qml
        qml/screens/HomeScreen.qml
        qml/screens/FlyScreen.qml
        qml/screens/PlanScreen.qml
        qml/screens/SetupScreen.qml
        qml/screens/SettingsScreen.qml
)

target_include_directories(rgcs PRIVATE src)

target_link_libraries(rgcs PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Sql
    Qt6::Positioning
    Qt6::Location
    Qt6::Multimedia
    Qt6::SerialPort
    Qt6::Network
)

if(APPLE)
    set_target_properties(rgcs PROPERTIES
        MACOSX_BUNDLE TRUE
        MACOSX_BUNDLE_BUNDLE_NAME "RGCS"
        MACOSX_BUNDLE_GUI_IDENTIFIER "com.rgcs.gcs"
    )
endif()
