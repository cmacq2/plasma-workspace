/***************************************************************************
 *   Copyright 2013 Sebastian Kügler <sebas@kde.org>                       *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU Library General Public License as       *
 *   published by the Free Software Foundation; either version 2 of the    *
 *   License, or (at your option) any later version.                       *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU Library General Public License for more details.                  *
 *                                                                         *
 *   You should have received a copy of the GNU Library General Public     *
 *   License along with this program; if not, write to the                 *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddonsComponents

import org.kde.private.systemtray 2.0 as SystemTray


KQuickControlsAddonsComponents.MouseEventListener {
    id: taskItemContainer
    objectName: "taskItemContainer"

    height: root.itemSize + (units.smallSpacing * 2)
    width: snExpanded ? parent.width : height

    hoverEnabled: true

    property variant task: null
    property bool isCurrentTask: (root.expandedTask == modelData)

    property bool isHiddenItem: false
    property int location: plasmoid.location

    function hideToolTip() {
        toolTip.hideToolTip()
    }

    Timer {
        id: hidePopupTimer
        interval: 10
        running: false
        repeat: false
        onTriggered: {
            print("hidetimer triggered, collapsing " + (root.expandedTask == null) )
            if (root.expandedTask == null) {
                plasmoid.expanded = false
            }
        }
    }

    // opacity is raised when: plasmoid is collapsed, we are the current task, or it's hovered
    opacity: (containsMouse || !plasmoid.expanded || isCurrentTask) || (plasmoid.expanded && root.expandedTask == null) ? 1.0 : 0.6
    Behavior on opacity { NumberAnimation { duration: units.shortDuration * 3 } }


    property int taskStatus: modelData && modelData.status
    property int taskType: modelData && modelData.type
    property Item expandedItem: modelData && modelData.taskItemExpanded
    property Item expandedStatusItem: null
    property bool snExpanded: false

    property bool isExpanded: modelData !== undefined && modelData.expanded === true

    onIsExpandedChanged: {
        if (isExpanded) {
            var task;
            if (root.expandedTask) {
                task = root.expandedTask;
            }
            root.expandedTask = modelData;

            if (task && task !== modelData) {
                task.expanded = false;
            }
        } else if (root.expandedTask == modelData) {
            root.expandedTask = null;
        }
    }


    PulseAnimation {
        targetItem: taskItemContainer
        running: modelData && modelData.status === SystemTray.Task.NeedsAttention && units.longDuration > 0
    }

    // Fallback for when units.longDuration is off, use the Attention icon
    Timer {
        id: needsAttentionTimer
        interval: 1000
        repeat: true
        running: modelData && modelData.status === SystemTray.Task.NeedsAttention && units.longDuration == 0

        onRunningChanged: {
            if (!running) {
                sniLoader.item.useAttentionIcon = false;
            }
        }

        onTriggered: {
            if (sniLoader.item.useAttentionIcon) {
                sniLoader.item.useAttentionIcon = false;
            } else {
                sniLoader.item.useAttentionIcon = true;
            }
        }
    }

    onWidthChanged: updatePlasmoidGeometry()
    onHeightChanged: updatePlasmoidGeometry()

    function updatePlasmoidGeometry() {
        if (modelData && modelData.taskItem != undefined) {
            var _size = Math.min(taskItemContainer.width, taskItemContainer.height);
            var _m = (taskItemContainer.height - _size) / 2

            modelData.taskItem.anchors.verticalCenter = taskItemContainer.verticalCenter;
            if (isHiddenItem) {
                modelData.taskItem.x = 0;
            } else {
                modelData.taskItem.anchors.centerIn = taskItemContainer;
            }
            modelData.taskItem.height = _size;
            modelData.taskItem.width = isHiddenItem ? _size * 1.5 : _size;
        }
    }

    PlasmaCore.ToolTipArea {
        id: toolTip
        anchors.fill: parent

        active: !isExpanded
        icon: modelData && modelData.taskItem ? modelData.taskItem.icon : sniLoader.item.icon
        mainText: modelData && modelData.taskItem ? modelData.taskItem.toolTipMainText : sniLoader.item.toolTipMainText
        subText: modelData && modelData.taskItem ? modelData.taskItem.toolTipSubText : (sniLoader.item && sniLoader.item.toolTipSubText ? sniLoader.item.toolTipSubText : "")
        location: modelData && modelData.taskItem ? taskItemContainer.location : sniLoader.item.location
        Loader {
            id: sniLoader
            anchors.fill: parent
        }
    }

    Component.onCompleted: {
        if (taskType == SystemTray.Task.TypeStatusItem) {
            sniLoader.source = "StatusNotifierItem.qml";
        } else if (modelData && modelData.taskItem != undefined) {
            sniLoader.source = "PlasmoidItem.qml";
            modelData.taskItem.parent = taskItemContainer;
            modelData.taskItem.z = -1;
            updatePlasmoidGeometry();
        } else {
            console.warning("Trying to add item to system tray of an unknown type. Ignoring");
        }
    }
}
