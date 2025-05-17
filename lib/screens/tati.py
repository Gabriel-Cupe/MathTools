import numpy as np
import trimesh
from scipy.spatial.transform import Rotation as R

class Estructura:
    def __init__(self):
        self.vertices = []
        self.lines = []
        self.mesh = trimesh.Trimesh()
    
    def add_vertex(self, pos):
        self.vertices.append(pos)
        return len(self.vertices)
    
    def add_line(self, start_idx, end_idx):
        self.lines.append([start_idx, end_idx])
    
    def add_sphere(self, pos, radius, color=[1, 1, 1]):
        sphere = trimesh.creation.icosphere(radius=radius)
        sphere.apply_translation(pos)
        sphere.visual.vertex_colors = color
        self.mesh += sphere
    
    def add_ellipsoid(self, pos, direction, radius, flatten=0.5, color=[1, 1, 1]):
        # Crear esfera y aplanarla
        ellipsoid = trimesh.creation.icosphere(radius=radius)
        ellipsoid.apply_scale([1, 1, flatten])
        
        # Rotar para alinear con la dirección (corrección del error)
        target = direction / np.linalg.norm(direction)
        rot = R.align_vectors([target], [[0, 0, 1]])[0]  # Ahora sí recibe dos listas
        ellipsoid.apply_transform(rot)
        
        ellipsoid.apply_translation(pos + direction * radius * 0.7)
        ellipsoid.visual.vertex_colors = color
        self.mesh += ellipsoid
    
    def export(self, filename):
        # Exportar wireframe (.obj)
        with open(filename, "w") as f:
            for v in self.vertices:
                f.write(f"v {v[0]} {v[1]} {v[2]}\n")
            for line in self.lines:
                f.write(f"l {line[0]} {line[1]}\n")
        
        # Exportar componentes 3D (.glb)
        if hasattr(self.mesh, 'export'):
            self.mesh.export(filename.replace(".obj", "_components.glb"))

# --- Componentes atómicos ---
def Hidrogeno(struct, pos):
    struct.add_sphere(pos, 0.15, [0.8, 0.8, 0.8])  # Esfera gris
    struct.add_ellipsoid(pos, np.array([1, 0, 0]), 0.2, 0.3, [1, 1, 1])  # Lóbulo enlazante

def ParNoEnlazante(struct, pos):
    struct.add_ellipsoid(pos, np.array([1, 0, 0]), 0.3, 0.2, [1, 0, 0])  # Lóbulo rojo

def ParEnlazante(struct, pos):
    struct.add_ellipsoid(pos, np.array([1, 0, 0]), 0.3, 0.2, [1, 1, 1])  # Lóbulo blanco

def Enlace(struct, start, end, radius=0.07):
    cylinder = trimesh.creation.cylinder(radius=radius, segment=np.array([start, end]))
    cylinder.visual.vertex_colors = [0.9, 0.9, 0.9]
    struct.mesh += cylinder

# --- Layouts base ---
def Tetraedro(center=[0, 0, 0], scale=1.0):
    verts = np.array([
        [1, 1, 1], [1, -1, -1], [-1, 1, -1], [-1, -1, 1]
    ]) * scale / np.linalg.norm([1,1,1])
    verts += center
    return verts

# --- Función UNIR ---
def UNIR(puntos, *estructuras):
    result = Estructura()
    offset = 0
    for punto, struct in zip(puntos, estructuras):
        for v in struct.vertices:
            result.add_vertex(np.array(v) + np.array(punto))
        for line in struct.lines:
            result.add_line(line[0] + offset, line[1] + offset)
        offset += len(struct.vertices)
        result.mesh += struct.mesh
    return result

# --- Ejemplo: SO₄²⁻ ---
def SO4_2():
    # Tetraedro central (azufre)
    centro = Estructura()
    centro.add_sphere([0, 0, 0], 0.4, [1, 1, 0])  # Azufre (amarillo)
    
    # 4 oxígenos en posiciones tetraédricas
    oxigenos = []
    for i, pos in enumerate(Tetraedro(scale=1.5)):
        oxi = Estructura()
        oxi.add_sphere(pos, 0.3, [1, 0, 0])  # Oxígeno (rojo)
        Enlace(oxi, [0, 0, 0], pos)  # Enlace S-O σ
        
        if i < 2:  # Enlaces dobles (σ + π)
            ParEnlazante(oxi, pos)
            Enlace(oxi, [0, 0, 0], pos, 0.05)  # Enlace π (delgado)
        else:      # Pares solitarios
            ParNoEnlazante(oxi, pos)
        
        oxigenos.append(oxi)
    
    # Unir todo
    return UNIR([[0,0,0]] + [[0,0,0]] * 4, centro, *oxigenos)  # Pivote en [0,0,0]

# --- Generar archivos ---
if __name__ == "__main__":
    # Layouts base
    cruz = Estructura()
    for v in [[1,0,0], [-1,0,0], [0,1,0], [0,-1,0], [0,0,1], [0,0,-1]]:
        cruz.add_vertex(v)
    cruz.lines = [[1,2], [3,4], [5,6]]
    cruz.export("cruz.obj")
    
    triangulo = Estructura()
    verts = [[1,0,0], [-0.5, 0.87, 0], [-0.5, -0.87, 0], [0,0,1], [0,0,-1]]
    baricentro = np.mean(verts[:3], axis=0)
    triangulo.vertices = verts + [baricentro.tolist()]
    triangulo.lines = [[1,2], [2,3], [3,1], [4,5], [1,6], [2,6], [3,6]]
    triangulo.export("triangulo.obj")
    
    # SO₄²⁻
    so4 = SO4_2()
    so4.export("so4.obj")
    print("¡Archivos generados con éxito!")