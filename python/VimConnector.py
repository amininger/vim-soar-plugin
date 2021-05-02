""" Adds features to the SoarClient to buffer output and repeat commands """

from pysoarlib import AgentConnector

from VimWriter import VimWriter

class VimConnector(AgentConnector):
    def __init__(self, client, vim_writer):
        AgentConnector.__init__(self, client)

        self.vim_writer = vim_writer
        self.last_soar_command = None
        self.last_print_command = None

    def on_init_soar(self):
        self.last_soar_command = None
        self.last_print_command = None

    def start_buffering_output(self):
        self.buffered_output = []
        self.client.print_handler = lambda message: self.buffered_output.append(message)

    def stop_buffering_output(self):
        self.client.print_handler = lambda message: self.vim_writer.write(message, VimWriter.MAIN_PANE, clear=False, scroll=True)
        self.client.print_handler("\n".join(self.buffered_output))
        self.buffered_output = []


    def record_command(self, cmd):
        if cmd.startswith("p ") or cmd.startswith("print "):
            self.last_print_command = cmd
        self.last_soar_command = cmd

    def repeat_last_print(self, depth_change=0, print_res=False):
        """ Will redo the last print command, with the option to change the depth """
        if self.last_print_command is None:
            result = "No saved print command"
        else:
            args = self.last_print_command.split()
            # Here we assume the previous command is either 'p <s2>' or 'p <s2> -d 3'
            if len(args) < 3:
                args.append('-d')
            if len(args) < 4:
                args.append(str(1))
            args[3] = str(int(args[3])+depth_change)
            result = self.client.execute_command(" ".join(args), print_res)
        return result

