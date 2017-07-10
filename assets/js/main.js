import '../css/app.scss'
import Elm from '../elm/Main'

const root = document.getElementById('root')

const app = Elm.Main.embed(root)

const { ports } = app

const moves = {
  KeyW: 'up',
  KeyS: 'down',
  KeyA: 'left',
  KeyD: 'right',
}
window.addEventListener('keydown', ({code}) => {
  const move = moves[code]
  if (move !== undefined) {
    ports.newMove.send(move)
  }
})


