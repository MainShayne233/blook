import '../css/app.scss'
import Elm from '../elm/Main'

const root = document.getElementById('root')

const app = Elm.Main.embed(root)

const { ports } = app

window.addEventListener('keydown', ({code}) => {
  ports.keyPress.send(code)
})


