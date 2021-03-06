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
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
// import org.kde.plasma.components 2.0 as PlasmaComponents
// import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.private.systemtray 2.0 as SystemTray
import "Layout.js" as LayoutManager

Item {
    id: root
    objectName: "SystemTrayRootItem"

    property bool vertical: (plasmoid.formFactor == PlasmaCore.Types.Vertical)

    //This way the configuration pages can access it
    property QtObject systrayHost: host

    Plasmoid.toolTipMainText: ""
    Plasmoid.toolTipSubText: ""

    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation
    Plasmoid.onExpandedChanged: {
        if (!plasmoid.expanded && root.expandedTask) {
            root.expandedTask.expanded = false;
            root.expandedTask = null;
        }
    }

    property int preferredItemSize: 128 // will be set by the grid, just needs a high-enough default

    // Sizes depend on the font, and thus on DPI
    property int baseSize: theme.mSize(theme.defaultFont).height
    property int itemSize: LayoutManager.alignedSize(Math.min(baseSize * 2, preferredItemSize))

    //a pointer to the Task* that is the current one expanded, that shows full ui
    property QtObject expandedTask: null;

    function togglePopup() {
        if (!plasmoid.expanded) {
            plasmoid.expanded = true
        }
    }

    Plasmoid.compactRepresentation: CompactRepresentation { }

    Plasmoid.fullRepresentation: ExpandedRepresentation {
        Layout.minimumWidth: Layout.minimumHeight * 1.75
        Layout.minimumHeight: units.gridUnit * 14
        Layout.preferredWidth: Layout.minimumWidth
        Layout.preferredHeight: Layout.minimumHeight * 1.5
    }

    Connections {
        target: plasmoid.configuration
        onApplicationStatusShownChanged: host.setCategoryShown(SystemTray.Task.ApplicationStatus, plasmoid.configuration.applicationStatusShown);

        onCommunicationsShownChanged: host.setCategoryShown(SystemTray.Task.Communications, plasmoid.configuration.communicationsShown);

        onSystemServicesShownChanged: host.setCategoryShown(SystemTray.Task.SystemServices, plasmoid.configuration.systemServicesShown);

        onHardwareControlShownChanged: host.setCategoryShown(SystemTray.Task.Hardware, plasmoid.configuration.hardwareControlShown);

        onMiscellaneousShownChanged: host.setCategoryShown(SystemTray.Task.Unknown, plasmoid.configuration.miscellaneousShown);

        onExtraItemsChanged: host.plasmoidsAllowed = plasmoid.configuration.extraItems
    }

    Component.onCompleted: {
        //script, don't bind
        host.plasmoidsAllowed = initializePlasmoidList()

        host.setCategoryShown(SystemTray.Task.ApplicationStatus, plasmoid.configuration.applicationStatusShown);

        host.setCategoryShown(SystemTray.Task.Communications, plasmoid.configuration.communicationsShown);

        host.setCategoryShown(SystemTray.Task.SystemServices, plasmoid.configuration.systemServicesShown);

        host.setCategoryShown(SystemTray.Task.Hardware, plasmoid.configuration.hardwareControlShown);

        host.setCategoryShown(SystemTray.Task.Unknown, plasmoid.configuration.miscellaneousShown);
    }

    function initializePlasmoidList() {
        var newKnownItems = [];
        var newExtraItems = [];

        //NOTE:why this? otherwise the interpreter will execute host.defaultPlasmoids() on
        //every access of defaults[], resulting in a very slow iteration
        var defaults = [];
        //defaults = defaults.concat(host.defaultPlasmoids);
        defaults = host.defaultPlasmoids.slice()
        var candidate;

        //Add every plasmoid that is both not enabled explicitly and not already known
        for (var i = 0; i < defaults.length; ++i) {
            candidate = defaults[i];
            if (plasmoid.configuration.knownItems.indexOf(candidate) === -1) {
                newKnownItems.push(candidate);
                if (plasmoid.configuration.extraItems.indexOf(candidate) === -1) {
                    newExtraItems.push(candidate);
                }
            }
        }

        if (newExtraItems.length > 0) {
            plasmoid.configuration.extraItems = plasmoid.configuration.extraItems.slice().concat(newExtraItems);
        }
        if (newKnownItems.length > 0) {
            plasmoid.configuration.knownItems = plasmoid.configuration.knownItems.slice().concat(newKnownItems);
        }

        return plasmoid.configuration.extraItems;
    }

    SystemTray.Host {
        id: host
        rootItem: plasmoid
        formFactor: "desktop"
        showAllItems: plasmoid.configuration.showAllItems
        forcedShownItems: plasmoid.configuration.shownItems
        forcedHiddenItems: plasmoid.configuration.hiddenItems
    }

    SystemTray.TasksProxyModel {
        id: shownTasksModel
        host: host
        category: SystemTray.TasksProxyModel.ShownTasksCategory
    }

    SystemTray.TasksProxyModel {
        id: hiddenTasksModel
        host: host
        category: SystemTray.TasksProxyModel.HiddenTasksCategory
    }
}
