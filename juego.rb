require 'rubygems'
require 'gosu'
#require 'Conway.rb'

#Clase para graficar el algoritmo, basada en la gem gosu
class MyWindow < Gosu::Window
	# alto =640, ancho=480
	def initialize(largo =800, ancho=600)
		#Defino las variables a utilizar
		@largo =largo
		@ancho= ancho
		#Variables para definir el tamaño de cada cuadrado del grid
		@x1=largo/10
		@y1=ancho/10
		@LargoCuadrito = largo/@x1
		@AnchoCuadrito= ancho/@y1

		#Define el tamaño de la ventana 
		super largo, ancho, false

		#Titulo de la ventana del Juego
		self.caption = "Mi Juego de la Vida"

		#colores de la casillas segun este viva o muerta
		@colorFondo= Gosu::Color.new(0xff808080)
		@colorViva= Gosu::Color.new(0xff330000)
		@colorMuerta= Gosu::Color.new(0xff3300ff)
		
		#Creo la matriz inicial segun el tamaño de la pantalla
		@a=MatriX.new(@x1,@y1)
		# le doy vida a las primeras celdas
		@a.PrimeraRonda(@a,@x1*@y1/2)
		@NoTurno=0
		

	end
#Metodo que utiliza gosu para actualizar el estado del juego
	def update
		#creo una clase juego con la matriz que ya cree
		@Juego=Juego.new(@a.tablero,@x1,@y1)
		@Juego.turno!
		@NoTurno += 1
		puts "numero de turno: #{@NoTurno}"		
		
	end

	def draw
		# Dibujo el fondo
		draw_quad(0, 0,@colorFondo,@largo,0,@colorFondo,@largo,@ancho,@colorFondo,0,@ancho,@colorFondo)

		#ciclo para dibujar el tablero
		for f in 0..@y1-1
			for c in 0..@x1-1
				if @a.tablero[f][c] == false
					draw_quad(c * @LargoCuadrito,f * @AnchoCuadrito, @colorMuerta, c * @AnchoCuadrito + (@AnchoCuadrito - 1), f * @LargoCuadrito, @colorMuerta, c * @AnchoCuadrito + (@AnchoCuadrito - 1), f * @LargoCuadrito + (@LargoCuadrito - 1), @colorMuerta, c * @AnchoCuadrito, f * @LargoCuadrito + (@LargoCuadrito - 1), @colorMuerta)
				else
					draw_quad(c * @LargoCuadrito,f * @AnchoCuadrito, @colorViva, c * @AnchoCuadrito + (@AnchoCuadrito - 1), f * @LargoCuadrito, @colorViva, c * @AnchoCuadrito + (@AnchoCuadrito - 1), f * @LargoCuadrito + (@LargoCuadrito - 1), @colorViva, c * @AnchoCuadrito, f * @LargoCuadrito + (@LargoCuadrito - 1), @colorViva)
				end
			end
		end
	end



	# clase para que aparezca el cursor
	def needs_cursor?
    	true
 	 end

 
end

#clase que use de manera provisional para imprimir las matrices en orden
class ImprimeMatriz
	attr_accessor :matriz, :x1, :y1
	def initialize (matriz,x1,y1)
		@x1=x1
		@y1=y1
		@matriz = matriz
		
		for c in 0..@y1-1
			for f in 0..@x1-1
		   		print " | ", @matriz[c][f]
			end
			puts "----------------"
		end		
		
	end
end	



#creo la clase Juego donde se va a crear la matriz e iniciar el juego
class Juego
	attr_accessor :matriz, :x1, :y1, :c,:f, :cuantos, :matrizTMP
	
	def initialize (matriz,x1,y1)
		@x1=x1
		@y1=y1
		@matriz = matriz
		@cuantos = 0 #variable que contendra la cantidad de vecinos de la celda analizada

#MATRIZ temporal para saber como va a cambiar segun las reglas en el siguiente turno
		@matrizTMP = Array.new(@x1) do |fila| 
					 	Array.new(@y1) do |col|
						 end
				  	 end
		#Le asigno el valor de la matriz principal		   
		for f in 0..@y1-1
			for c in 0..@x1-1
		   		@matrizTMP[f][c]=@matriz[f][c]
			end
		end		
	end #fin del def initilize


	#METODO PARA ACTUALIZAR EL TABLERO SEGUN LAS REGLAS
	def turno!
		#CICLO PARA PASAR POR EL ARREGLO HASTA ENCONTRAR LAS CELDAS VIVAS O LAS CELULAS MUERTAS QUE CUMPLEN CON LA REGLA 4
		for f in 0..@y1-1
			for c in 0..@x1-1

				if @matriz[f][c] == true
					Vecinos(@matriz,f,c) #checo cuantos vecinos tengo alrededor
					Reglas(@matriz,@matrizTMP,@cuantos,f,c)#verifico si cumple alguna regla de conway

						
				else # de lo contrario la celda esta en false y debo comprobar la regla 4
					
					Vecinos(@matriz,f,c) #regreso cuantos vecinos tiene vivos
					#REGLA 4. Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
					if @cuantos == 3
						@matrizTMP[f][c] = true
					end
				end #cierra if
			end #cierra ciclo for
		end #cierra ciclo for 

		#ACTUALIZO LA MATRIZ CON LA TEMPORAL QUE ES COMO DEBE QUEDAR AHORA EL JUEGO
		for f in 0..@y1-1
			for c in 0..@x1-1
		   		@matriz[f][c]=@matrizTMP[f][c]
			end
		end

	end #cierra el metodo initialize


#Metodo para determinar cuantos vecinos tengo alrededor que esten vivos de una celda que esta viva
	def Vecinos(matriz,y,x)
		@matriz=matriz #recibo todo el tablero
		#recibo las coordenas donde estoy 
		@x=x 
		@y=y 
		@cuantos=0 #variable para guardar cuantos vecinos tengo en estado true

		#variables que se posicionan alrededor de la celda en true, Valido no estar en los extremos

		if @y == 0
			tmpY = @y
			finalY=1
		elsif @y == @y1-1
			tmpY = @y-1
			finalY=1
		else
			tmpY = @y-1
			finalY=2
		end

		if @x == 0
			tmpX=@x
			finalX=1
		elsif @x == @x1-1
			tmpX=@x-1
			finalX=1
		else
			tmpX=@x-1
			finalX=2
		end
			

		#hago un ciclo iniciando por la celda que se encuentra a la derecha y arriba de la celda en la que estoy 
		for filas in tmpY..tmpY+finalY
			for columna in tmpX..tmpX+finalX
				if @matriz[filas][columna] == true 

					if columna == @x && filas == @y #si la celda que estoy validando esta en true la cuento, al menos que sea donde ya estaba		
						@cuantos=@cuantos
					else
						@cuantos=@cuantos+1
					end
					
				end	
			end
		end
	end #final de metodo Vecinos

	#metodo para validar las reglas de conway
	def Reglas(matriz,matrizTMP,cantVecinos,y,x)
		@matriz=matriz
		@cantVecinos=cantVecinos
		@x=x
		@y=y
		@matrizTMP=matrizTMP #matriz temporal de como quedara la siguiente ronda


		#REGLA 1. Any live cell with fewer than two live neighbours dies, as if caused by under-population.

		if @cantVecinos < 2
			#puts "REGLA 1"
			@matrizTMP[y][x]=false

		#REGLA 2. Any live cell with two or three live neighbours lives on to the next generation.

		elsif @cantVecinos ==2 || @cantVecinos == 3
			#puts "REGLA 2"
		 	@matrizTMP[y][x]=true

		#Regla 3. Any live cell with more than three live neighbours dies, as if by overcrowding.

		elsif @cantVecinos > 3
			#puts "REGLA 3"
		 	@matrizTMP[y][x]=false
		end
		
	end #final metodo reglas

end #final de clase


#Clase para crear la matriz segun el largo y ancho de la pantalla
class MatriX
	attr_accessor :fila, :col, :tablero
	def initialize (col=5,fila=5)
		@fila=fila
		@col=col
#creo el array que contendra el tablero
		@tablero = Array.new(fila) do |fila| 
					 Array.new(col) do |col|
					 end
				   end
		
#Lleno el array con valores false
		for x1 in 0..fila-1
			for y1 in 0..col-1
				@tablero[x1][y1] = false
			end
		end

	end

#Primera Ronda es el metodo para volver a la vida las primeras celdas del manera aleatoria, segun el numero de columnas*filas/2 es el numero de randoms va a realizar
	def PrimeraRonda(matriz,numAleatorios)	
		for x1 in 0..numAleatorios
				@tablero[Random.rand(fila-1)][Random.rand(col-1)]= true
		end
	end

end

#linea para ver graficamente el juego
MyWindow.new.show
