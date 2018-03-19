BEGIN = -10
END = 10
WIDTH = END-BEGIN

container = null
camera = null
scene = null
renderer = null
mesh = null
controls = null
uniforms = null

###
getColor = (max, min, val)->
  MIN_L = 40
  MAX_L = 100
  color = new THREE.Color()
  h = 0/240
  s = 80/240
  l = (((MAX_L-MIN_L)/(max-min))*val)/240
  color.setHSL(h,s,l)
  color
###
getColor = (max, min, val)->
  colours = [
    {red:0, green:0, blue:255}
    {red:0, green:255, blue:255}
    {red:0, green:255, blue:0}
    {red:255, green:255, blue:0}
    {red:255, green:0, blue:0}
  ]
  temp = new ColourGradient(min, max, colours)
  c = temp.getColour(val)
  new THREE.Color("rgb(#{c.red},#{c.green},#{c.blue})");


initGrid = ()->
  plane_geometry = new THREE.PlaneGeometry(WIDTH,WIDTH)
  plane_material = new THREE.MeshLambertMaterial {
    color: 0xf0f0f0
    shading: THREE.FlatShading
    overdraw: 0.5
    side: THREE.DoubleSide
  }
  plane = new THREE.Mesh(plane_geometry, plane_material)
  scene.add(plane)

  geometry = new THREE.Geometry()
  for i in [BEGIN..END] by 2
    geometry.vertices.push new THREE.Vector3(BEGIN, i,      0)
    geometry.vertices.push new THREE.Vector3(END,   i,      0)
    geometry.vertices.push new THREE.Vector3(i,     BEGIN,  0)
    geometry.vertices.push new THREE.Vector3(i,     END,    0)

  material = new THREE.LineBasicMaterial { color: 0x999999, opacity: 0.2 }

  line = new THREE.Line(geometry, material)
  line.type = THREE.LinePieces
  scene.add(line)


fun1 = (x, y)-> 1.5*(Math.cos(Math.sqrt(x*x+y*y))+1)
fun2 = (x, y)-> Math.cos(x/3)*Math.cos(y/3) + Math.sin(x/3) + 1.5

makeData = (fun)->
  data = []
  for x in [BEGIN...END]
    row = ({x:x, y:y, z: fun(x,y)} for y in [BEGIN...END])
    data.push row
  data


makeSurface = (data)->
  scene.remove(mesh) if mesh

  geometry = new THREE.Geometry()
  material = new THREE.ShaderMaterial {
    uniforms: {}
    attributes: {}
    vertexShader:   '''
      void main() {
        gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
      }
    '''
    fragmentShader: '''
      void main() {
        gl_FragColor = vec4( 1.0, 0.0, 0.0, 1.0 );
      }
    '''
    blending:       THREE.AdditiveBlending
    depthTest:      false
    transparent:    true
  }

  mesh = new THREE.Mesh(geometry, material)
  scene.add(mesh)

  colors = []
  width = data.length
  height = data[0].length

  for col in data
    for val in col
      geometry.vertices.push new THREE.Vector3(val.x, val.y, val.z)
      colors.push getColor(2.5, 0, val.z)

  offset = (x,y)-> x*width + y

  for x in [0...width-1]
    for y in [0...height-1]
      vec0 = new THREE.Vector3()
      vec1 = new THREE.Vector3()
      n_vec = new THREE.Vector3()
      # one of two triangle polygons in one rectangle
      vec0.subVectors( geometry.vertices[offset(x,y)], geometry.vertices[offset(x+1,y)] )
      vec1.subVectors( geometry.vertices[offset(x,y)], geometry.vertices[offset(x,y+1)] )
      n_vec.crossVectors(vec0,vec1).normalize()
      geometry.faces.push(new THREE.Face3(
        offset(x,y)
        offset(x+1,y)
        offset(x,y+1)
        n_vec
        [ colors[offset(x,y)], colors[offset(x+1,y)], colors[offset(x,y+1)] ]))
      geometry.faces.push(new THREE.Face3(
        offset(x,y)
        offset(x,y+1)
        offset(x+1,y)
        n_vec.negate()
        [ colors[offset(x,y)], colors[offset(x,y+1)], colors[offset(x+1,y)] ]))
      # the other one
      vec0.subVectors(geometry.vertices[offset(x+1,y)], geometry.vertices[offset(x+1,y+1)])
      vec1.subVectors(geometry.vertices[offset(x,y+1)], geometry.vertices[offset(x+1,y+1)])
      n_vec.crossVectors(vec0, vec1).normalize()
      geometry.faces.push(new THREE.Face3(
        offset(x+1,y)
        offset(x+1,y+1)
        offset(x,y+1)
        n_vec
        [colors[offset(x+1,y)],colors[offset(x+1,y+1)],colors[offset(x,y+1)] ]))
      geometry.faces.push(new THREE.Face3(
        offset(x+1,y)
        offset(x,y+1)
        offset(x+1,y+1)
        n_vec.negate()
        [colors[offset(x+1,y)],colors[offset(x,y+1)],colors[offset(x+1,y+1)] ]))


init = ()->
  scene = new THREE.Scene()

  container = document.getElementById 'container'
  camera = new THREE.PerspectiveCamera( 45, window.innerWidth/window.innerHeight, 0.1, 2000 )
  camera.position.set(0, -20, 20)
  scene.add(camera)

  for position in [[1,1,1], [-1,-1,1], [-1,1,1], [1,-1,1]]
    light= new THREE.DirectionalLight(0xdddddd)
    light.position.set( position[0], position[1], 0.4*position[2])
    scene.add(light)

  initGrid()

  renderer = new THREE.WebGLRenderer( { antialias: true } )
  renderer.setClearColor( 0xffffff )
  renderer.setPixelRatio( window.devicePixelRatio )
  renderer.setSize( window.innerWidth, window.innerHeight )

  container.appendChild( renderer.domElement )
  controls = new THREE.TrackballControls( camera )


switchData = ()->
  makeSurface( makeData(fun1) )

animate = ()->
  requestAnimationFrame( animate )
  render()

render = ()->
  time = Date.now() * 0.001
  controls.update()
  renderer.render( scene, camera )

init()
makeSurface(makeData(fun2))
animate()
#render()
