import gleam/int
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

import gleam/list
import lustre/effect.{type Effect}

type Model {
  Model(total: Int, todos: List(Todo))
}

type Todo {
  Todo(id: Int, priority: Int, state: State, name: String)
}

type State {
  NotStarted
  Started
  Finished
}

fn state_to_css_class(state: State) -> String {
  case state {
    NotStarted -> "state-not-started"
    Started -> "state-started"
    Finished -> "state-finished"
  }
}

fn init(_args) -> #(Model, Effect(Message)) {
  let model =
    Model(total: 1, todos: [
      Todo(id: 1, priority: 1, state: NotStarted, name: "test todo"),
    ])

  #(model, effect.none())
}

type Message {
  UserClickecAddTodo
  UserClickedSaveTodo
  UserClickedChangeTodoState(id: Int)
  UserClickedSaveTodoState(id: Int, new_state: State)
  UserClickedRenameTodo(id: Int)
  UserClickedSaveTodoName(id: Int, new_name: String)
  UserClickedRemoveTodo(id: Int)
}

fn update(model: Model, message: Message) -> #(Model, Effect(Message)) {
  case message {
    UserClickedRemoveTodo(id) -> #(
      Model(
        ..model,
        todos: list.filter(model.todos, fn(todo_element) {
          todo_element.id != id
        }),
      ),
      effect.none(),
    )

    _ -> #(model, effect.none())
  }
}

fn view(model: Model) -> Element(Message) {
  html.div([attribute.id("page-content")], [
    html.h1([attribute.id("welcome")], [
      html.text("Welcome to my todo app"),
    ]),

    html.ul(
      [attribute.id("todo-list")],
      list.map(model.todos, fn(todo_element) {
        html.li(
          [
            attribute.class("todo-element"),
            attribute.class(state_to_css_class(todo_element.state)),
          ],
          [
            element.text(todo_element.name),
            html.button(
              [
                attribute.commandfor("edit-modal"),
                attribute.command("show-modal"),
              ],
              [element.text("Edit")],
            ),
            html.button(
              [event.on_click(UserClickedRemoveTodo(todo_element.id))],
              [element.text("Delete")],
            ),
          ],
        )
      }),
    ),
    html.dialog([attribute.id("edit-modal")], [
      element.text("Modal"),
      html.button(
        [attribute.commandfor("edit-modal"), attribute.command("close")],
        [element.text("Close")],
      ),
    ]),
  ])
}

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}
