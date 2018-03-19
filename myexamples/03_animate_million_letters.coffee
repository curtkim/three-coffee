fontSize = 16
lettersPerSide = 16

scene = new THREE.Scene()

makeTexture = ()->
  c = document.createElement('canvas')
  c.width = c.height = fontSize*lettersPerSide
  ctx = c.getContext('2d')
  ctx.font = fontSize+'px Monospace'

  for y in [0...lettersPerSide]
    for x in [0...lettersPerSide]
      ctx.fillText(String.fromCharCode(lettersPerSide*y+x), x*fontSize, -(8/32)*fontSize+(y+1)*fontSize)

  tex = new THREE.Texture(c)
  tex.flipY = false
  tex.needsUpdate = true
  tex

makeBookGeometry = (str)->
  geo = new THREE.Geometry()

  j=0
  ln=0

  for ch, i in str
    code = str.charCodeAt(i)
    cx = code % lettersPerSide
    cy = Math.floor(code / lettersPerSide)

    geo.vertices.push(
      new THREE.Vector3( j*1.1+0.05, ln*1.1+0.05, 0 )
      new THREE.Vector3( j*1.1+1.05, ln*1.1+0.05, 0 )
      new THREE.Vector3( j*1.1+1.05, ln*1.1+1.05, 0 )
      new THREE.Vector3( j*1.1+0.05, ln*1.1+1.05, 0 )
    )
    geo.faces.push new THREE.Face3(i*4+0, i*4+1, i*4+2)
    geo.faces.push new THREE.Face3(i*4+0, i*4+2, i*4+3)
    ox=(cx+0.05)/lettersPerSide
    oy=(cy+0.05)/lettersPerSide
    Off=0.9/lettersPerSide
    sz = lettersPerSide*fontSize
    geo.faceVertexUvs[0].push([
      new THREE.Vector2( ox, oy+Off )
      new THREE.Vector2( ox+Off, oy+Off )
      new THREE.Vector2( ox+Off, oy )
    ])
    geo.faceVertexUvs[0].push([
      new THREE.Vector2( ox, oy+Off )
      new THREE.Vector2( ox+Off, oy )
      new THREE.Vector2( ox, oy )
    ])
    if (code == 10)
      ln--
      j=0
    else
      j++

  geo

geo = makeBookGeometry '''
  The Project Gutenberg EBook of Metamorphosis, by Franz Kafka
  Translated by David Wyllie.
  '''

tex = makeTexture()

uniforms =
  time:
    type: "f"
    value: 1.0
  size:
    type: "v2"
    value: new THREE.Vector2(window.innerWidth, window.innerHeight)
  map:
    type: "t"
    value: tex
  effectAmount:
    type: "f"
    value: 0.0

shaderMaterial = new THREE.ShaderMaterial {
  uniforms: uniforms
  vertexShader: '''
    varying float vZ;
    uniform float time;
    uniform float effectAmount;
    varying vec2 vUv;

    mat3 rotateAngleAxisMatrix(float angle, vec3 axis) {
      float c = cos(angle);
      float s = sin(angle);
      float t = 1.0 - c;
      axis = normalize(axis);
      float x = axis.x, y = axis.y, z = axis.z;
      return mat3(
        t*x*x + c,    t*x*y + s*z,  t*x*z - s*y,
        t*x*y - s*z,  t*y*y + c,    t*y*z + s*x,
        t*x*z + s*y,  t*y*z - s*x,  t*z*z + c
      );
    }

    vec3 rotateAngleAxis(float angle, vec3 axis, vec3 v) {
      return rotateAngleAxisMatrix(angle, axis) * v;
    }

    void main() {
      float idx = floor(position.y/1.1)*80.0 + floor(position.x/1.1);
      vec3 corner = vec3(floor(position.x/1.1)*1.1, floor(position.y/1.1)*1.1, 0.0);
      vec3 mid = corner + vec3(0.5, 0.5, 0.0);
      vec3 rpos = rotateAngleAxis(idx+time, vec3(mod(idx,16.0), -8.0+mod(idx,15.0), 1.0), position - mid) + mid;
      vec4 fpos = vec4( mix(position,rpos,effectAmount), 1.0 );
      fpos.x += -35.0;
      fpos.z += ((sin(idx+time*2.0)))*4.2*effectAmount;
      fpos.y += ((cos(idx+time*2.0)))*4.2*effectAmount;
      vec4 mvPosition = modelViewMatrix * fpos;
      mvPosition.y += 10.0*sin(time*0.5+mvPosition.x/25.0)*effectAmount;
      mvPosition.x -= 10.0*cos(time*0.5+mvPosition.y/25.0)*effectAmount;
      vec4 p = projectionMatrix * mvPosition;
      vUv = uv;
      vZ = p.z;
      gl_Position = p;
      /*
      vec4 p = projectionMatrix * modelViewMatrix * vec4 (position, 1.0);
      vUv = uv;
      vZ = p.z;
      gl_Position = p;
      */
    }
  '''
  fragmentShader: '''
    varying float vZ;
    varying vec2 vUv;
    uniform float time;
    uniform float effectAmount;
    uniform vec2 size;
    uniform sampler2D map;
    void main() {
      vec2 d = gl_FragCoord.xy - (0.5+0.02*sin(time))*size*vec2(1.0, 1.0);
      vec4 diffuse = texture2D(map, vUv);
      float a = sin(time*0.3)*2.0*3.14159;
      d = vec2( d.x*cos(a) + d.y*sin(a), -d.x*sin(a) + d.y*cos(a));
      vec2 rg = vec2(0.0)+abs(d)/(0.5*size);
      float b = abs(vZ) / 540.0;
      gl_FragColor = mix(diffuse, vec4(rg,b,diffuse.a), 0.5);
    }
  '''
}
shaderMaterial.transparent = true
shaderMaterial.depthTest = false

mat = new THREE.MeshBasicMaterial({map: tex})
mat.transparent = true;

book = new THREE.Mesh geo, shaderMaterial #mat
scene.add(book)


camera = new THREE.PerspectiveCamera(45,1,4,40000)
camera.position.z = 40
camera.lookAt(scene.position)
scene.add(camera)

renderer = new THREE.WebGLRenderer({antialias: true})
renderer.setClearColor( 0xffffff )
document.body.appendChild(renderer.domElement)

window.onresize = ()->
  renderer.setSize(window.innerWidth, window.innerHeight)
  camera.aspect = window.innerWidth / window.innerHeight
  camera.updateProjectionMatrix()
window.onresize()

animate = ()->
  uniforms.time.value += 0.01
  uniforms.effectAmount.value = 0.1
  #book.position.y += 0.03
  renderer.render(scene, camera)
  requestAnimationFrame(animate, renderer.domElement)

animate()
