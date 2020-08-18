""" Initializes a Rosie agent in the soar vim debugger and will display chat and action info in different panes """
import sys
import vim

from rosie import ActionStackConnector, LanguageConnector, RosieAgent

from VimWriter import VimWriter

class VimRosieAgent(RosieAgent):
    def __init__(self, writer, config_filename=None, **kwargs):
        self.vim_writer = writer
        RosieAgent.__init__(self, config_filename=config_filename, 
                print_handler = lambda message: writer.write(message, VimWriter.MAIN_PANE, clear=False, scroll=True),
                spawn_debugger=False, write_to_stdout=True, **kwargs)

        if self.messages_file != None:
            with open(self.messages_file, 'r') as f:
                lines = ( line.strip() for line in f.readlines() )
                # Filter empty lines and commented lines
                lines = ( line for line in lines if len(line) > 0 and line[0] != '#' )
                # Replace quotes with pipes
                lines = ( line.replace('"', '|') for line in lines )
                vim.command('let g:rosie_messages = ["' + '","'.join(lines) + '"]')

        self.connectors["language"] = LanguageConnector(self, 
            lambda message: writer.write(message, VimWriter.MAIN_PANE, clear=False, scroll=True))
        self.connectors["language"].register_message_callback(
            lambda message: writer.write(message, VimWriter.SIDE_PANE_TOP, clear=False, scroll=True))
        self.connectors["language"].register_script_callback(
            lambda message: writer.write(message, VimWriter.SIDE_PANE_TOP, clear=False, scroll=True))

        self.connectors["action_stack"] = ActionStackConnector(self, print_handler = 
            lambda message: writer.write(message, VimWriter.MAIN_PANE, clear=False, scroll=True))
        self.connectors["action_stack"].register_task_change_callback(
            lambda message: writer.write(message, VimWriter.SIDE_PANE_MID, clear=False, scroll=True, strip=False))

    def update_debugger_info(self):
        stack = self.agent.ExecuteCommandLine("p --stack", False)
        self.vim_writer.write(stack, VimWriter.SIDE_PANE_BOT, clear=True, scroll=True)

    def connect(self):
        super().connect()
        self.agent.RunSelf(1)

    def start_buffering_output(self):
        self.buffered_output = []
        self.print_handler = lambda message: self.buffered_output.append(message)

    def stop_buffering_output(self):
        self.print_handler = lambda message: self.vim_writer.write(message, VimWriter.MAIN_PANE, clear=False, scroll=True)
        self.print_handler("\n".join(self.buffered_output))
        self.buffered_output = []


        



