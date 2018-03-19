container = null
camera = null
controls = null
scene = null
renderer = null

mesh = null
texture = null

worldWidth = 256
worldDepth = 256
worldHalfWidth = worldWidth / 2
worldHalfDepth = worldDepth / 2

clock = new THREE.Clock()

init = ()->
  container = document.getElementById 'container'
  camera = new THREE.PerspectiveCamera( 60, window.innerWidth / window.innerHeight, 1, 20000 )

  scene = new THREE.Scene()

  controls = new THREE.FirstPersonControls( camera )
  controls.movementSpeed = 1000
  controls.lookSpeed = 0.1

  data = generateHeight( worldWidth, worldDepth )
  camera.position.y = data[ worldHalfWidth + worldHalfDepth * worldWidth ] * 10 + 500

  geometry = new THREE.PlaneBufferGeometry( 7500, 7500, worldWidth - 1, worldDepth - 1 )
  geometry.applyMatrix( new THREE.Matrix4().makeRotationX( - Math.PI / 2 ) )

  vertices = geometry.attributes.position.array

  for i in [0...vertices.length]
    vertices[ 3*i + 1 ] = data[ i ] * 10

  texture = new THREE.Texture(
    generateTexture( data, worldWidth, worldDepth ),
    THREE.UVMapping,
    THREE.ClampToEdgeWrapping,
    THREE.ClampToEdgeWrapping )
  texture.needsUpdate = true

  mesh = new THREE.Mesh( geometry, new THREE.MeshBasicMaterial( { map: texture } ) )
  scene.add( mesh )

  renderer = new THREE.WebGLRenderer()
  renderer.setClearColor( 0xbfd1e5 )
  renderer.setPixelRatio( window.devicePixelRatio )
  renderer.setSize( window.innerWidth, window.innerHeight )

  container.appendChild( renderer.domElement )


generateHeight = ( width, height )->
  size = width * height
  data = new Uint8Array( size )

  perlin = new ImprovedNoise()
  quality = 1
  z = Math.random() * 100

  for j in [0...4]
    for i in [0...size]
      x = i % width
      y = ~~ ( i / width )
      data[i] += Math.abs( perlin.noise( x/quality, y/quality, z ) * quality * 1.75 )
    quality *= 5
  data


generateTexture = ( data, width, height )->
  [canvas, canvasScaled, context, image, imageData] = [null, null, null, null, null]
  [level, diff, vector3, sun, shade] = [null, null, null, null]

  vector3 = new THREE.Vector3( 0, 0, 0 )

  sun = new THREE.Vector3( 1, 1, 1 )
  sun.normalize()

  canvas = document.createElement( 'canvas' )
  canvas.width = width
  canvas.height = height

  context = canvas.getContext( '2d' )
  context.fillStyle = '#000'
  context.fillRect( 0, 0, width, height )

  image = context.getImageData( 0, 0, canvas.width, canvas.height )
  imageData = image.data

  for i in [0...imageData.length] by 4
    j = i/4
    vector3.x = data[ j - 2 ] - data[ j + 2 ]
    vector3.y = 2
    vector3.z = data[ j - width * 2 ] - data[ j + width * 2 ]
    vector3.normalize()

    shade = vector3.dot( sun )

    imageData[ i ] = ( 96 + shade * 128 ) * ( 0.5 + data[ j ] * 0.007 )
    imageData[ i + 1 ] = ( 32 + shade * 96 ) * ( 0.5 + data[ j ] * 0.007 )
    imageData[ i + 2 ] = ( shade * 96 ) * ( 0.5 + data[ j ] * 0.007 )


  context.putImageData( image, 0, 0 )

  canvasScaled = document.createElement 'canvas'
  canvasScaled.width = width * 4
  canvasScaled.height = height * 4

  context = canvasScaled.getContext( '2d' )
  context.scale( 4, 4 )
  context.drawImage( canvas, 0, 0 )

  image = context.getImageData( 0, 0, canvasScaled.width, canvasScaled.height )
  imageData = image.data

  for i in [0...imageData.length] by 4
    v = ~~ ( Math.random() * 5 )
    imageData[ i ] += v
    imageData[ i + 1 ] += v
    imageData[ i + 2 ] += v

  context.putImageData( image, 0, 0 )

  canvasScaled


animate = ()->
  requestAnimationFrame( animate )
  render()

render = ()->
  controls.update( clock.getDelta() )
  renderer.render( scene, camera )

init()
animate()