import '../css/app.scss'
import Elm from '../elm/Main'

const root = document.getElementById('root')

const app = Elm.Main.embed(root)

const { ports } = app

const moves = {
  KeyW: 'move_up',
  KeyS: 'move_down',
  KeyA: 'move_left',
  KeyD: 'move_right',
  KeyQ: 'rotate_counter_clockwise',
  KeyE: 'rotate_clockwise',
  Space: 'shoot',
}
window.addEventListener('keydown', ({code}) => {
  const move = moves[code]
  if (move !== undefined) {
    ports.newMove.send(move)
  }
})


