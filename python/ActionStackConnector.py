""" Used by the Rosie Agent to print information about the actions Rosie is performing """
import sys
import vim
import traceback

from string import digits
from pysoarlib import AgentConnector

from VimWriter import VimWriter

def task_to_string(task_id):
    handle_wme = task_id.FindByAttribute("action-handle", 0)
    arg1_wme = task_id.FindByAttribute("arg1", 0)
    arg2_wme = task_id.FindByAttribute("arg2", 0)

    task = handle_wme.GetValueAsString() + "("
    if arg1_wme != None:
        task += task_arg_to_string(arg1_wme.ConvertToIdentifier())
    if arg2_wme != None:
        if arg1_wme != None:
            task += ", "
        task += task_arg_to_string(arg2_wme.ConvertToIdentifier())
    task += ")"

    return task

def task_arg_to_string(arg_id):
    arg_type = arg_id.FindByAttribute("arg-type", 0).GetValueAsString()
    if arg_type == "object":
        id_wme = arg_id.FindByAttribute("id", 0)
        return obj_arg_to_string(id_wme.ConvertToIdentifier())
    elif arg_type == "predicate":
        handle_str = arg_id.FindByAttribute("handle", 0).GetValueAsString()
        obj2_str = obj_arg_to_string(arg_id.FindByAttribute("2", 0).ConvertToIdentifier())
        return "%s(%s)" % ( handle_str, obj2_str )
    elif arg_type == "waypoint":
        wp_id = arg_id.FindByAttribute("id", 0).ConvertToIdentifier()
        return wp_id.FindByAttribute("handle", 0).GetValueAsString()
    elif arg_type == "concept":
        return arg_id.GetChildString("handle")
    return "?"

def obj_arg_to_string(obj_id):
    pred_order = [ ["size"], ["color"], ["name", "shape", "category"] ]
    preds_id = obj_id.FindByAttribute("predicates", 0).ConvertToIdentifier()
    obj_desc = ""
    for pred_list in pred_order:
        for pred in pred_list:
            pred_wme = preds_id.FindByAttribute(pred, 0)
            if pred_wme != None:
                obj_desc += pred_wme.GetValueAsString() + " "
                break
    if len(obj_desc) > 0:
        obj_desc = obj_desc[:-1]

    return obj_desc.translate(None, digits)

class ActionStackConnector(AgentConnector):
    def __init__(self, agent, writer):
        AgentConnector.__init__(self, agent, print_handler=lambda message: writer.write(message, VimWriter.MAIN_PANE, clear=False, scroll=True))

        self.print_action = lambda message: writer.write(message, VimWriter.SIDE_PANE_MID, clear=False, scroll=True)

        self.add_output_command("started-action")
        self.add_output_command("completed-action")

    def on_init_soar(self):
        pass

    def on_input_phase(self, input_link):
        pass

    def on_output_event(self, command_name, root_id):
        if command_name == "started-action":
            self.process_started_action(root_id)
        elif command_name == "completed-action":
            self.process_completed_action(root_id)

    def process_started_action(self, root_id):
        try:
            task_id = root_id.FindByAttribute("execution-operator", 0).ConvertToIdentifier()
            padding = "  " * (int(root_id.FindByAttribute("depth", 0).GetValueAsString()) - 1)
            self.print_action(padding + ">" + task_to_string(task_id))
        except:
            self.print_handler("Error Parsing Started Action")
        root_id.CreateStringWME("handled", "true")

    def process_completed_action(self, root_id):
        try:
            task_id = root_id.FindByAttribute("execution-operator", 0).ConvertToIdentifier()
            padding = "  " * (int(root_id.FindByAttribute("depth", 0).GetValueAsString()) - 1)
            self.print_action(padding + "<" + task_to_string(task_id))
        except:
            self.print_handler("Error Parsing Completed Action")
            self.print_handler(traceback.format_exc())
        root_id.CreateStringWME("handled", "true")
