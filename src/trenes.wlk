
// DEPOSITO

class Deposito {
	
	const formaciones = null
	const locomotoras = []
	
	method agregarLocomotora(unaLocomotora) = locomotoras.add(unaLocomotora)
	
	method agregarFormacion(unaFormacion) = formaciones.add(unaFormacion)
		
	method quitarUnaLocomotora (unaLocomotora) = locomotoras.remove(unaLocomotora)
	
	method vagonesMasPesados() {
		return formaciones.map { formacion => formacion.vagonMasPesado() }.asSet()
	}
	
	method necesitaConductorExperimentado() {
		return formaciones.any { formacion => formacion.esCompleja() }
	}
	
	method agregarLocomotoraSiNoPuedeMoverse(unaFormacion) {
		
		if ( unaFormacion.puedeMoverse() ) {}
		else {
			const locomotorasValidas = locomotoras.filter { locomotora => ( locomotora.arrastreUtil() +
					unaFormacion.empujeParaMoverse() ) >= 0
				}
			if ( not  locomotorasValidas.isEmpty() ) {
				unaFormacion.agregarUnaLocomotora ( locomotorasValidas.first()	)
				self.quitarUnaLocomotora ( locomotorasValidas.first() )
			}
		}
	
	}
	
}

// FORMACION

class Formacion {
	
	const locomotoras = null
	const vagones = null
	
	method agregarUnaLocomotora(unaLocomotora) = locomotoras.add(unaLocomotora)
	
	method agregarUnVagon(unVagon) = vagones.add(unVagon)
	
	method vagonesLivianos() {
		return vagones.count { vagon => ( vagon.peso() < 2500 )}
	}
	
	method velocidadMaxima() {
		return locomotoras.map { locomotora => locomotora.velocidad() }.min()
	}
	
	method esEficiente() {
		return locomotoras.all { locomotora => locomotora.esEficiente() }
	}
	
	method puedeMoverse() {
		return locomotoras.sum { locomotora => locomotora.arrastreUtil() } >
			vagones.sum { vagon => vagon.peso() }
	}
	
	method empujeParaMoverse() {
		return (locomotoras.sum { locomotora => locomotora.arrastreUtil() }
			- vagones.sum { vagon => vagon.peso() }).min(0)
	}
	
	method vagonMasPesado() {
		return vagones.max { vagon => vagon.peso()}
	}
	
	method esCompleja() {
		return vagones.size() + locomotoras.size() > 20
			or self.pesoTotal() > 10000
	}
	
	method pesoTotal() {
		const formacion = locomotoras + vagones
		return formacion.sum { unidad => unidad.peso() }
	}
	
}

class FormacionCortaDistancia inherits Formacion {

	
	method estaBienArmada() {
		return self.puedeMoverse() and not self.esCompleja()
	}
	
	method velocidadLimite() {
		return 60.min( self.velocidadMaxima() )
	}
	
}

class FormacionLargaDistancia inherits Formacion {
	
	var uneCiudadesGrandes = false
		
	method estaBienArmada() {
		return self.puedeMoverse() and vagones.all { vagon =>
			vagon.tieneSuficientesBaniosPorPasajero()
		}
	}
	
	method unirCiudadesGrandes() {
		uneCiudadesGrandes = true
	}
	
	method velocidadLimite() {
		var velocidadMaxima
		if ( uneCiudadesGrandes ) {
			velocidadMaxima = 200.min( self.velocidadMaxima() )
		}
		else {
			velocidadMaxima = 150.min( self.velocidadMaxima() )
		}
		return velocidadMaxima
	}	
	
}

class FormacionAltaVelocidad inherits FormacionLargaDistancia {
	
	override method estaBienArmada() {
		return self.velocidadMaxima() > 250 and vagones.all {
			vagon => vagon.peso() < 2500
		}
	}
}	

// VAGON

class VagonPasajeros {
	
	const ancho = null
	const largo = null
	const banios = null
	
	method capacidadPasajeros() {
		var pasajeros = 0
		if (ancho > 2.5) { pasajeros = largo * 10 }
		else { pasajeros = largo * 8 }
		return pasajeros
	}
	
	method peso() = self.capacidadPasajeros() * 80
	method carga() = 0
	
	method tieneSuficientesBaniosPorPasajero() {
		return banios >= self.capacidadPasajeros() / 50
	}
	
}

class VagonCarga {
	
	const carga = null
	
	method capacidadPasajeros() = 0
	method peso() = carga + 160
	method carga() = carga
	method tieneSuficientesBaniosPorPasajero() = true
	
}

// LOCOMOTORA

class Locomotora {
	
	const property peso = null
	const arrastre = null
	const property velocidad = null
	
	method arrastreUtil() = arrastre - peso
	method esEficiente() = arrastre > peso * 5
	
}