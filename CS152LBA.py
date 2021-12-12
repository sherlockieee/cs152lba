from tkinter import Frame, Label, Button, Tk, simpledialog
from pyswip import Prolog, Functor, Variable, Atom, registerForeign, call
import numpy as np
import pylcs


class ExpertSystem:
    def __init__(self, master):
        frame = Frame(master)
        frame.grid()

        self.chatBox = Label(
            master,
            text="Welcome to Minerva CovidBot Berlin",
            bd=1,
            bg="white",
            fg="black",
            width=100,
            height=8,
            justify="center",
        )
        self.chatBox.place(x=5, y=5, height=500, width=800)

        self.Button = Button(
            master,
            text="Begin system",
            bg="blue",
            activebackground="light blue",
            width=12,
            height=5,
            command=lambda: queryGenerator(),
        )
        self.Button.place(x=5, y=510, height=88, width=800)


prolog = Prolog()
prolog.consult("kb.pl")
retractall = Functor("retractall")
known = Functor("known", 3)


def system_response(response: str) -> None:
    """
    Displays system response to the GUI and returns True to Prolog
    """
    app.chatBox["text"] += f"SYSTEM: {response}"
    return True


def user_response(response: str) -> None:
    """
    Displays user response to the GUI and returns True to Prolog
    """
    app.chatBox["text"] += f"YOU: {response}\n"
    return True


def read_py(A, V, Y):
    """
    Askables (Yes/No questions) to user and sends the response to Prolog.
    Yes is usually evaluated as True and any other input as False.
    :param A: Askable prompted to user.
    :param V: Value user needs to agree (yes) or disagree
                (any other input) with.
    :param Y: Value Prolog will match with as True.
                Normally it is 'Yes'.
    :returns True if Y is a Prolog Variable else False.
    """
    if isinstance(Y, Variable):
        system_response(f"{str(A)} {str(V)}?\n")
        response = simpledialog.askstring(
            "Input", f"{str(A)} {str(V)}?", parent=root
        ).lower()
        Y.unify(response)
        return True
    else:
        return False


def read_py_menu(A, Y, Menu):
    """
    Asks the user for input based on a menu. Choosing the index of the option
    as well as the exact text of the option would work. When the response
    has the best LCS match with an option above 10% it is the default response.
    :param A: Askable the user must answer.
    :param V: Answer from user to Prolog.
    :param Menu: Provided options user can select.
    :returns True if Y is a Prolog variable, else False.
    """
    if isinstance(Y, Variable):
        list_for_lcs = []
        question = "" + str(A) + "\n"
        for i, x in enumerate(Menu):
            question += "\t" + str(i) + " .  " + str(x) + "\n"
            list_for_lcs.append(str(x))
        response = get_menu_input(question, Menu, list_for_lcs)
        user_response(response)
        Y.unify(response)
        return True
    else:
        return False


def get_menu_input(question, Menu, lst_lcs):
    """
    This method contains the logic of identifying user's choice from the dialog box.
    Users can either select numbers or write.
    If user selects a number it has to be a valid number from the options given.
    If user selects a string it has to be the best match among all options and > 10%.
    :param Menu: The options that the user needs to choose from; stored as Atoms.
    :param lst_lcs: Options in an array.
    :returns user's option.
    """
    system_response(question)
    from_user = simpledialog.askstring("Input", question, parent=root)
    response_int = float("inf")
    try:
        response_int = int(from_user)
        response = str(Menu[response_int])
    except:
        response = from_user.lower()
        response = most_appropriate(response, lst_lcs)
    return response


def most_appropriate(response, lst_lcs):
    """
    Choose the most appropriate option given the user's response.
    It matches the choice using percentage LCS (Least Common Subsequence) match.
    If the best match > 10%, it is returned.
    If not, user will be asked to re-select.
    :parm response: User input.
    :param lst_lcs: Options stored as a list of strings.
    :returns User's option.
    """
    lcs = pylcs.lcs_of_list(response, lst_lcs)
    lengths = []
    for option in lst_lcs:
        lengths.append(len(option))
    similarities = np.array(lcs) / np.array(lengths)
    option_idx = np.argmax(similarities)
    if similarities[option_idx] < 0.1:
        return response
    return lst_lcs[option_idx]


system_response.arity = 1
user_response.arity = 1
read_py.arity = 3

read_py_menu.arity = 3

registerForeign(read_py)
registerForeign(system_response)
registerForeign(user_response)
registerForeign(read_py_menu)


def queryGenerator():
    # this prints the values that are chosen,correctly
    # Each we query clear all the known values
    call(retractall(known))
    app.chatBox["text"] = "=" * 80 + "\n"
    q = list(prolog.query("answer(X).", maxresult=1))
    for v in q:
        app.chatBox["text"] += f"ANSWER ==> {str(v['X'])}\n"
    app.Button.configure(text="Start again")


root = Tk()
root.geometry("810x600")
root.resizable(0, 0)
root.config(bg="red")
app = ExpertSystem(root)
root.title("Minerva Covid Chatbot")
root.mainloop()
