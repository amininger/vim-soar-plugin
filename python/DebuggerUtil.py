import vim

def insert_text_at_cursor(text, scroll=True):
    """ Will insert the given text at the cursor and scroll to the end (if scroll==True) """
    lines = text.split("\n")
    win = vim.current.window
    win.buffer.append(lines, win.cursor[0])
    if scroll:
        win.cursor = (win.cursor[0] + len(lines), 0)

def print_id(client, soar_id, depth=1):
    """ Will return the printout of the given id to the given depth """
    return client.execute_command("p " + soar_id + " -d " + str(depth))

def get_current_substate(client):
    """ Returns the identifier symbol of the deepest state for the given SoarClient
        (Prints the stack and gets the bottom state)"""
    stack = client.execute_command("p --stack").split("\n")
    # Find the last line in the stack printout that matches '  :      ==>S: S124 (impasse-type)'
    for line in reversed(stack):
        words = line.split()
        if len(words) >= 3 and words[1] == '==>S:':
            return words[2]
    return "S1"

def get_current_operator(client):
    """ Returns the symbol of the currently selected operator on the deepest state for the given SoarClient
        (Prints the stack and gets the bottom operator) """
    stack = client.execute_command("p --stack").split("\n")
    # Find the last line in the stack printout that matches '  :        O: O452 (operator-name)'
    for line in reversed(stack):
        words = line.split()
        if len(words) >= 3 and words[1] == 'O:':
            return words[2]
    return ""

def print_chunks(client, num=-1):
    """ Prints a list of the [num] most recently learned chunks (or all if num=-1)"""
    chunks = client.execute_command("pc").split("\n")
    if num > 0:
        chunks = chunks[0:num]
    return "\n".join(reversed(chunks))

def get_filtered_rules(client, pattern):
    """ Returns a printout of all rules that contain the given pattern """
    all_rules = client.execute_command("p").split("\n")
    return "".join(client.execute_command("p " + rule_name) for rule_name in all_rules 
            if pattern in rule_name)

def get_filtered_chunks(client, pattern):
    """ Returns a printout of all chunks that match the given pattern """
    all_chunks = client.execute_command("pc").split("\n")
    return "".join(client.execute_command("p " + chunk_name) for chunk_name in all_chunks
            if pattern in chunk_name)

def excise_rules_matching_pattern(client, pattern):
    all_rules = client.execute_command("p").split("\n")
    for rule_name in all_rules:
        if pattern in rule_name:
            client.execute_command("excise " + rule_name, print_res=True)

def write_fired_rules(client, filename):
    """ Writes out all rules that have fired so far into a single file """
    firing_counts = client.execute_command("fc").split("\n")
    with open(filename, 'w') as f:
        for line in firing_counts:
            args = line.split()
            # Want lines of the form     N: production*name
            if len(args) < 2 or args[0][-1] != ':':
                continue
            count = int(args[0][:-1]) # strip colon
            if count == 0:
                continue
            rule_name = args[1]
            f.write(client.execute_command("p " + rule_name))
