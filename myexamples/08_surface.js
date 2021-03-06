// Generated by CoffeeScript 1.7.1
(function() {
  var BEGIN, END, WIDTH, animate, camera, container, controls, fun, getColor, init, initData, initGraph, initGrid, loader, mesh, render, renderer, scene, uniforms;

  BEGIN = -10;

  END = 10;

  WIDTH = END - BEGIN;

  container = null;

  camera = null;

  scene = null;

  renderer = null;

  mesh = null;

  controls = null;

  uniforms = null;


  /*
  getColor = (max, min, val)->
    MIN_L = 40
    MAX_L = 100
    color = new THREE.Color()
    h = 0/240
    s = 80/240
    l = (((MAX_L-MIN_L)/(max-min))*val)/240
    color.setHSL(h,s,l)
    color
   */

  getColor = function(max, min, val) {
    var c, colours, temp;
    colours = [
      {
        red: 0,
        green: 0,
        blue: 255
      }, {
        red: 0,
        green: 255,
        blue: 255
      }, {
        red: 0,
        green: 255,
        blue: 0
      }, {
        red: 255,
        green: 255,
        blue: 0
      }, {
        red: 255,
        green: 0,
        blue: 0
      }
    ];
    temp = new ColourGradient(min, max, colours);
    c = temp.getColour(val);
    return new THREE.Color("rgb(" + c.red + "," + c.green + "," + c.blue + ")");
  };

  loader = new THREE.TextureLoader();

  initGrid = function() {
    var positions, textureUrls;
    textureUrls = ['textures/30_13.png', 'textures/30_14.png', 'textures/31_13.png', 'textures/31_14.png'];
    positions = [
      {
        x: -0.5 * WIDTH,
        y: -0.5 * WIDTH
      }, {
        x: 0.5 * WIDTH,
        y: -0.5 * WIDTH
      }, {
        x: -0.5 * WIDTH,
        y: 0.5 * WIDTH
      }, {
        x: 0.5 * WIDTH,
        y: 0.5 * WIDTH
      }
    ];
    return async.map(textureUrls, function(url, cb) {
      return loader.load(url, function(texture) {
        return cb(null, texture);
      });
    }, function(err, textures) {
      var i, material, plane, texture, _i, _len, _results;
      _results = [];
      for (i = _i = 0, _len = textures.length; _i < _len; i = ++_i) {
        texture = textures[i];
        material = new THREE.MeshBasicMaterial({
          map: texture
        });
        plane = new THREE.Mesh(new THREE.PlaneGeometry(WIDTH, WIDTH), material);
        plane.position.x = positions[i].x;
        plane.position.y = positions[i].y;
        _results.push(scene.add(plane));
      }
      return _results;
    });

    /*
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
     */
  };

  fun = function(x, y) {
    return Math.cos(x / 3) * Math.cos(y / 3) + Math.sin(x / 3) + 1.5;
  };

  initData = function() {
    var data, row, x, y, _i;
    data = [];
    for (x = _i = BEGIN; BEGIN <= END ? _i < END : _i > END; x = BEGIN <= END ? ++_i : --_i) {
      row = (function() {
        var _j, _results;
        _results = [];
        for (y = _j = BEGIN; BEGIN <= END ? _j < END : _j > END; y = BEGIN <= END ? ++_j : --_j) {
          _results.push({
            x: x,
            y: y,
            z: fun(x, y)
          });
        }
        return _results;
      })();
      data.push(row);
    }
    return data;
  };

  initGraph = function() {
    var col, colors, data, geometry, height, material, n_vec, offset, val, vec0, vec1, width, x, y, _i, _j, _k, _l, _len, _len1, _ref, _ref1;
    data = initData();
    geometry = new THREE.Geometry();
    colors = [];
    width = data.length;
    height = data[0].length;
    console.log(width, height);
    for (_i = 0, _len = data.length; _i < _len; _i++) {
      col = data[_i];
      for (_j = 0, _len1 = col.length; _j < _len1; _j++) {
        val = col[_j];
        geometry.vertices.push(new THREE.Vector3(val.x, val.y, val.z));
        colors.push(getColor(2.5, 0, val.z));
      }
    }
    offset = function(x, y) {
      return x * width + y;
    };
    for (x = _k = 0, _ref = width - 1; 0 <= _ref ? _k < _ref : _k > _ref; x = 0 <= _ref ? ++_k : --_k) {
      for (y = _l = 0, _ref1 = height - 1; 0 <= _ref1 ? _l < _ref1 : _l > _ref1; y = 0 <= _ref1 ? ++_l : --_l) {
        vec0 = new THREE.Vector3();
        vec1 = new THREE.Vector3();
        n_vec = new THREE.Vector3();
        vec0.subVectors(geometry.vertices[offset(x, y)], geometry.vertices[offset(x + 1, y)]);
        vec1.subVectors(geometry.vertices[offset(x, y)], geometry.vertices[offset(x, y + 1)]);
        n_vec.crossVectors(vec0, vec1).normalize();
        geometry.faces.push(new THREE.Face3(offset(x, y), offset(x + 1, y), offset(x, y + 1), n_vec, [colors[offset(x, y)], colors[offset(x + 1, y)], colors[offset(x, y + 1)]]));
        geometry.faces.push(new THREE.Face3(offset(x, y), offset(x, y + 1), offset(x + 1, y), n_vec.negate(), [colors[offset(x, y)], colors[offset(x, y + 1)], colors[offset(x + 1, y)]]));
        vec0.subVectors(geometry.vertices[offset(x + 1, y)], geometry.vertices[offset(x + 1, y + 1)]);
        vec1.subVectors(geometry.vertices[offset(x, y + 1)], geometry.vertices[offset(x + 1, y + 1)]);
        n_vec.crossVectors(vec0, vec1).normalize();
        geometry.faces.push(new THREE.Face3(offset(x + 1, y), offset(x + 1, y + 1), offset(x, y + 1), n_vec, [colors[offset(x + 1, y)], colors[offset(x + 1, y + 1)], colors[offset(x, y + 1)]]));
        geometry.faces.push(new THREE.Face3(offset(x + 1, y), offset(x, y + 1), offset(x + 1, y + 1), n_vec.negate(), [colors[offset(x + 1, y)], colors[offset(x, y + 1)], colors[offset(x + 1, y + 1)]]));
      }
    }
    material = new THREE.MeshLambertMaterial({
      vertexColors: THREE.VertexColors,
      transparent: true,
      opacity: 0.5
    });
    mesh = new THREE.Mesh(geometry, material);
    return scene.add(mesh);
  };

  init = function() {
    scene = new THREE.Scene();
    container = document.getElementById('container');
    camera = new THREE.PerspectiveCamera(45, window.innerWidth / window.innerHeight, 0.1, 2000);
    camera.position.set(0, -20, 20);
    scene.add(camera);
    scene.add(new THREE.AmbientLight(0xffffff));

    /*
    z = 1
    x = 1
    y = 1
    for position in [[x,y,z], [-1*x,-1*y,z], [-1*x,y,z], [x,-1*y,z]]
      light= new THREE.DirectionalLight(0xdddddd)
      light.position.set( position[0], position[1], 0.4*position[2])
      scene.add(light)
    
      geometry = new THREE.BoxGeometry( 1,1,1 )
      material = new THREE.MeshBasicMaterial( { color: 0x00ff00 } )
      cube = new THREE.Mesh( geometry, material )
      cube.position.set(position[0],position[1],position[2])
      scene.add( cube )
     */
    initGrid();
    renderer = new THREE.WebGLRenderer({
      antialias: true
    });
    renderer.setClearColor(0xffffff);
    renderer.setPixelRatio(window.devicePixelRatio);
    renderer.setSize(window.innerWidth, window.innerHeight);
    container.appendChild(renderer.domElement);
    return controls = new THREE.TrackballControls(camera);
  };

  animate = function() {
    requestAnimationFrame(animate);
    return render();
  };

  render = function() {
    var time;
    time = Date.now() * 0.001;
    controls.update();
    return renderer.render(scene, camera);
  };

  init();

  initGraph();

  animate();

}).call(this);
