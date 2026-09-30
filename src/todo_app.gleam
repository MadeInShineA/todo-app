import gleam/int
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

import gleam/list
import lustre/effect.{type Effect}

pub type Model {
  Model(total: Int, todos: List(Todo))
}

pub type Todo {
  Todo(id: Int, priority: Int, state: State, name: String)
}

pub type State {
  NotStarted
  Started
  Finished
}

pub fn init(_args) -> #(Model, Effect(Message)) {
  let model = Model(total: 0, todos: [])

  #(model, effect.none())
}

pub type Message {
  UserClickecAddTodo
  UserClickedSaveTodo
  UserClickedChangeTodoState(id: Int)
  UserClickedSaveTodoState(id: Int, new_state: State)
  UserClickedRenameTodo(id: Int)
  UserClickedSaveTodoName(id: Int, new_name: String)
  UserClickedRemoveTodo(id: Int)
}

pub fn update(model: Model, message: Message) -> #(Model, Effect(Message)) {
  todo
}

pub fn view(model: Model) -> Element(Message) {
  html.h1([], [
    html.text("Welcome to my todo app"),
  ])
}

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}
