tool
extends EditorPlugin

var builder
var polygons = []
var selection: EditorSelection

func _enter_tree():
    builder = preload("res://addons/PolygonBuilder/PolygonBuilder.tscn").instance()
    add_control_to_container(CONTAINER_CANVAS_EDITOR_MENU, builder)

    builder.connect("to_polygon", self, "to_polygon")
    builder.connect("to_collision", self, "to_collision")
    builder.connect("to_occluder", self, "to_occluder")

    selection = get_editor_interface().get_selection()
    selection.connect("selection_changed", self, "selection_changed")
    update_polygon_array()


func _exit_tree():
    remove_control_from_container(CONTAINER_CANVAS_EDITOR_MENU, builder)


func buildPolygon(array, target):
    for polygon in array:
        if polygon is target:
            continue # If our polygon is the same type as target type, we skip it
        var newPoly = target.new() # New instance of target node
        if newPoly is LightOccluder2D: # LightOccluder2D doesn't contain "polygon" array
            newPoly.occluder = OccluderPolygon2D.new() # So we need to make OccluderPolygon
            newPoly.occluder.polygon = polygon.polygon # and insert it into targeted node
        else:
            if polygon is LightOccluder2D:
                newPoly.polygon = polygon.occluder.polygon
            else:
                newPoly.polygon = polygon.polygon

        newPoly.transform = polygon.transform
        var root = get_tree().get_edited_scene_root()
        var parent = root.get_node(polygon.get_parent().get_path())
        parent.add_child(newPoly)
        newPoly.set_owner(root)


func to_polygon():
    buildPolygon(polygons, Polygon2D)

func to_collision():
    buildPolygon(polygons, CollisionPolygon2D)

func to_occluder():
    buildPolygon(polygons, LightOccluder2D)

    
func selection_changed():
    update_polygon_array()


func update_polygon_array(): # Add any selected node to the list if it is some sort of Polygon
    polygons = []
    var appear = false
    for selected in selection.get_selected_nodes():
        if selected is Polygon2D or selected is CollisionPolygon2D or selected is LightOccluder2D:
            polygons.append(selected)
            appear = true
    if appear:
        builder.show()
    else:
        builder.hide()