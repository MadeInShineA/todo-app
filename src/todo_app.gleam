import gleam/int
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

import gleam/list
import gleam/option
import lustre/effect.{type Effect}

type Model {
  Model(total: Int, selected_todo: option.Option(Todo), todos: List(Todo))
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
    Model(total: 1, selected_todo: option.None, todos: [
      Todo(id: 1, priority: 1, state: NotStarted, name: "test todo"),
    ])

  #(model, effect.none())
}

type Message {
  UserClickedOpenAddModal
  UserClickedAddTodo(todo_item: Todo)

  UserClickedOpenDeleteModal(id: Int)
  UserClickedDeleteTodo(id: Int)

  UserClickedOpenEditModal(todo_item: Todo)
  UserClickedSaveTodo(todo_item: Todo)
}

fn update(model: Model, message: Message) -> #(Model, Effect(Message)) {
  case message {
    UserClickedOpenAddModal -> #(model, effect.none())
    UserClickedAddTodo(todo_item) -> #(
      Model(..model, todos: list.append(model.todos, [todo_item])),
      effect.none(),
    )

    UserClickedOpenDeleteModal(id) -> todo
    UserClickedDeleteTodo(id) -> #(
      Model(
        ..model,
        todos: list.filter(model.todos, fn(todo_element) {
          todo_element.id != id
        }),
      ),
      effect.none(),
    )

    UserClickedOpenEditModal(id) -> todo
    UserClickedSaveTodo(todo_item) -> #(
      Model(
        ..model,
        todos: list.map(model.todos, fn(item) {
          case item.id == todo_item.id {
            True -> todo_item
            False -> item
          }
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

    html.button(
      [
        attribute.commandfor("add-todo-modal"),
        attribute.command("show-modal"),
      ],
      [element.text("Add Todo")],
    ),

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
                attribute.commandfor("edit-todo-modal"),
                attribute.command("show-modal"),
              ],
              [element.text("Edit")],
            ),
            html.button(
              [
                attribute.commandfor("delete-todo-modal"),
                attribute.command("show-modal"),
              ],
              [element.text("Delete")],
            ),
          ],
        )
      }),
    ),
    html.dialog([attribute.id("add-todo-modal")], [
      html.div([], [
        element.text("Add Todo Modal"),
        html.button(
          [attribute.commandfor("add-todo-modal"), attribute.command("close")],
          [element.text("Close")],
        ),
      ]),
    ]),
    html.dialog([attribute.id("delete-todo-modal")], [
      html.div([], [
        element.text("Remove Todo Modal"),
        html.button(
          [
            attribute.commandfor("delete-todo-modal"),
            attribute.command("close"),
          ],
          [element.text("Close")],
        ),
      ]),
    ]),
    html.dialog([attribute.id("edit-todo-modal")], [
      html.div([], [
        element.text("Edit Todo Modal"),
        html.button(
          [
            attribute.commandfor("edit-todo-modal"),
            attribute.command("close"),
          ],
          [element.text("Close")],
        ),
      ]),
    ]),
  ])
}

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}
