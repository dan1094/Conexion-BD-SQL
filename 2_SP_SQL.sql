USE [cb1_lars]
GO
/****** Object:  StoredProcedure [dbo].[QRY_CONSULTAS_CASILLERO]    Script Date: 6/14/2019 12:54:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[QRY_CONSULTAS_CASILLERO]
	  @ID						INT					 = NULL

	 ,@ALIAS					NVARCHAR(50)		 =NULL
	 ,@NOMBRE					NVARCHAR(600)		 =NULL
	 ,@CELULAR					NVARCHAR(100)		 =NULL
	 ,@EMAIL					NVARCHAR(1200)		 =NULL
	 ,@TELEFONO					NVARCHAR(400)		 =NULL
	  
	 ,@cas_nombre     NVARCHAR(100)		= NULL,
	 @cas_empresa    NVARCHAR(100)		= NULL,
	 @cas_direccion  NVARCHAR(200)		= NULL,
	 @cas_ciudad_id  DECIMAL(18,0)		= NULL,
	 @cas_ciudad     NVARCHAR(50)		= NULL,
	 @cas_zip        NVARCHAR(50)		= NULL,
	 @cas_telefono   NVARCHAR(50)		= NULL,
	 @cas_fax        NVARCHAR(50)		= NULL,
	 @cas_email      NVARCHAR(200)		= NULL,
	 @cas_cuenta_id  INT				= NULL,
	 @cas_casillero  NVARCHAR(50)		= NULL,
	 @cas_ffw        CHAR(5)			= NULL,
	 @cas_password   NVARCHAR(50)		= NULL,
	 @cas_alias      NVARCHAR(50)		= NULL,
	 @cas_agencia_id INT				= NULL,
	 @cas_servicio   NVARCHAR(50)		= NULL,
	 @cas_pago       NVARCHAR(50)		= NULL,
	 @cas_sexo       NVARCHAR(50)		= NULL,
	 @cas_civil      NVARCHAR(50)		= NULL,
	 @cas_cedula     NVARCHAR(50)		= NULL,
	 @cas_celular    NVARCHAR(50)		= NULL,
	 @cas_fecha      NVARCHAR(50)		= NULL,
	 @cas_actividad  NVARCHAR(50)		= NULL,

	 @FFW				CHAR(5)		= NULL,

	 @ID_TIPO_ENVIO		INT = NULL,
	 @ULTIMO_ENVIO		BIT = NULL,
	 @ID_MANIFIESTO		INT = NULL,
	 @IDS_MANIFIESTOS	VARCHAR(500) = NULL,
	 @FECHA				DATETIME	= NULL,
	 @ID_CASILLERO		INT = NULL,
	 @ID_CUENTA			INT = NULL,
	 @COMENTARIO		VARCHAR(300) = NULL,
	 @DESCRIPCION		VARCHAR(300) = NULL,
	 @VALOR_DECLARADO	DECIMAL(18,2) = NULL,

	 @WHR				CHAR(13) = NULL,
	 @FECHA_FINAL		DATETIME = NULL,
	 @GUIMIA			VARCHAR(100) = NULL,

	 @MONEDA_ORIGEN		VARCHAR(10) = NULL,
	 @MONEDA_DESTINO	VARCHAR(10) = NULL,
	 @ID_PAGO	        VARCHAR(10) = NULL,

	 @FORMA_PAGO	    VARCHAR(300) = NULL,
	 @VALOR		        DECIMAL(18,2) = NULL,
	 @GUIA_KEY			VARCHAR(40) = NULL, --Jose Cardenas - Pagos payu desde cb1
	 @ID_USUARIO        INT = NULL

	 ,@OPERATION				TINYINT				 
AS
BEGIN
SET NOCOUNT ON;

	DECLARE @ENTRO			BIT				= 0
	
--------------------------------------------------------------------
--	0. Validar existencia casillero, si existe devuelve 1
--------------------------------------------------------------------
		IF @OPERATION = 0
		BEGIN
			SET @ENTRO = 1
			
			IF EXISTS (SELECT 1 FROM casilleros
			WHERE 
				--   cas_celular	=	@CELULAR  or 
				
				cas_alias	=	@ALIAS
				or cas_email	=	@EMAIL
				--or cas_nombre	=	@NOMBRE
				--or cas_telefono	=	@TELEFONO
				)

				SELECT CAST(1 AS BIT)
			ELSE
				SELECT CAST(0 AS BIT)
				
				RETURN 0     
		END

--------------------------------------------------------------------
--	1. Editar Casillero
--------------------------------------------------------------------
		IF @OPERATION = 1
		BEGIN
			UPDATE CASILLEROS 
			SET 
                  cas_empresa		  =	 @cas_empresa    
                 ,cas_direccion		  =	 @cas_direccion  
                 ,cas_zip			  =	 @cas_zip        
                 ,cas_telefono		  =	 @cas_telefono   
                 ,cas_fax			  =	 @cas_fax        
                 ,cas_email			  =	 @cas_email      
                 ,cas_password		  =	 @cas_password         
                 ,cas_sexo			  =	 @cas_sexo       
                 ,cas_civil			  =	 @cas_civil       
                 ,cas_celular		  =	 @cas_celular 
                 ,cas_actividad		  =  @cas_actividad  
				 ,cas_alias			  =  @cas_email
			WHERE
				cas_casillero_id = @ID

			select @@rowcount
			--SELECT @ID
			RETURN 0
		END

--------------------------------------------------------------------
--	2. Consultar Casillero
--------------------------------------------------------------------
		IF @OPERATION = 2
		BEGIN
			SET @ENTRO = 1
			
			
			SELECT [cas_casillero_id]
				  ,[cas_nombre]
				  ,[cas_empresa]
				  ,[cas_direccion]				
				  ,[cas_ciudad]
				  ,[cas_zip]
				  ,[cas_telefono]
				  ,[cas_fax]
				  ,[cas_email]
				  ,[cas_cuenta_id]
				  ,[cas_casillero]
				  ,[cas_ffw]
				  ,[cas_password]
				  ,[cas_alias]
				  ,[cas_agencia_id]
				  ,[cas_servicio]
				  ,[cas_fecha_creacion]
				  ,[cas_pago]
				  ,[cas_bloqueado]
				  ,[cas_verificado]
				  ,[cas_fecha_vencimiento]
				  ,[cas_comentario]
				  ,[cas_sexo]
				  ,[cas_civil]
				  ,[cas_celular]
				  ,[cas_cedula]
				  ,[cas_apellido]
				  ,[cas_fecha]
				  ,[cas_actividad]
				  ,[cas_ciudad_id]				 
				  ,paises.nombre as nombrePais,
				  paises.codigo as CodePais   
			  FROM [dbo].[CASILLEROS]				
			  INNER JOIN ciudades 
			  ON cas_ciudad_id=id_ciudad 
			  left join paises
			  on ciudades.id_pais = paises.id_pais
			  WHERE cas_casillero_id= @ID

			RETURN 0
		END

--------------------------------------------------------------------
--	3. Verificar login Casillero
--------------------------------------------------------------------
		IF @OPERATION = 3
		BEGIN
			SET @ENTRO = 1
			
			 SELECT 
				[cas_casillero_id]				  
			 FROM CASILLEROS 
			 WHERE 
				((CAST(UPPER(cas_email) AS varbinary(50)) = cast(UPPER(@cas_alias) as varbinary(50))) 
				or 
				(CAST(UPPER(cas_casillero) AS varbinary(50)) = cast(UPPER(@cas_alias) as varbinary(50))) )
				--(CAST(CAS_ALIAS AS varbinary(50)) = cast(@cas_alias as varbinary(50))) 
			 AND 
				(CAST(CAS_PASSWORD AS varbinary(50))=cast(@cas_password as varbinary(50)))


			RETURN 0
		END

--------------------------------------------------------------------
--	4. Obtener Agencias ??
--------------------------------------------------------------------
		IF @OPERATION = 4
		BEGIN
			SET @ENTRO = 1
			
			SELECT *  
			FROM dbo.AGENCIAS  
			WHERE 
				ffw = @FFW
			ORDER BY nombre

			RETURN 0
		END

--------------------------------------------------------------------
--	5. Obtener Servicios
--------------------------------------------------------------------
		IF @OPERATION = 5
		BEGIN
			SET @ENTRO = 1
			
			SELECT 
				CON.CFG_PRODUCTOCASILLERO ,  
				PRO.NOMBRE,
				CFG_AGEN_CASI 
			 FROM CONFIG CON 
			 INNER JOIN PRODUCTOS PRO  
			 ON CON.CFG_PRODUCTOCASILLERO = PRO.ID_PRODUCTO

			RETURN 0
		END
		
--------------------------------------------------------------------
--	6. Buscar Alertas
--------------------------------------------------------------------
		IF @OPERATION = 6
		BEGIN
			SET @ENTRO = 1

			IF(@FECHA_FINAL IS NOT NULL)
				SET @FECHA_FINAL =  DATEADD(DAY,1,@FECHA_FINAL)

			SELECT TOP 1 
				@CAS_CASILLERO = CAS_CASILLERO 
			FROM CASILLEROS
			WHERE CAS_CASILLERO_ID = @ID_CASILLERO 

			SELECT 
				alr_guimia,
				alr_casillero,
				alr_alerta_id,
				alr_fecha,
				alr_guimia,
				alr_body,
				alr_tienda,
				alr_valor,
				alr_descripcion,
				cast (isnull(alr_seguro, 0) as bit)   as alr_seguro,
				alr_direccion,
				alr_comentario 
            FROM ALERTAS
			WHERE 
				alr_casillero= @CAS_CASILLERO			
			AND alr_activada IS NULL 			
			AND (@FECHA IS NULL OR(@FECHA IS NOT NULL AND alr_fecha >= @FECHA))
			AND (@FECHA_FINAL IS NULL OR(@FECHA_FINAL IS NOT NULL AND alr_fecha <= @FECHA_FINAL))

			ORDER BY alr_alerta_id DESC


			RETURN 0
		END

--------------------------------------------------------------------
--	7. Tipos de envio 
--------------------------------------------------------------------
		IF @OPERATION = 7
		BEGIN
			SET @ENTRO = 1
			
			SELECT 
				CODTIPO,
				DESTIPO 
			FROM 
				TIPO_ENVIO

			RETURN 0
		END

--------------------------------------------------------------------
--	8. Aplicar tipo envio 
--------------------------------------------------------------------
		IF @OPERATION = 8
		BEGIN
			SET @ENTRO = 1
			
			UPDATE MANIFIESTO 
			SET
				 tipo_Envio = @ID_TIPO_ENVIO,
				 Ultimo_Envio = @ULTIMO_ENVIO			
			WHERE
				manifiesto_id = @ID_MANIFIESTO

			RETURN 0
		END

--------------------------------------------------------------------
--	9. Crear Alertas envios
--------------------------------------------------------------------
		IF @OPERATION = 9
		BEGIN
			SET @ENTRO = 1			

			--select * from ALERTAS_ENVIOS 
			INSERT INTO [dbo].[ALERTAS_ENVIOS]
					   ([alerManifId]
					   ,[alerCodTipo]
					   ,[alerFecha]
					   ,[alerCasId]
					   ,[alerCuenId]
					   ,[alerComentario]
					   ,[alerDescri]
					   ,[alerValdec])
				 VALUES
					   ( @IDS_MANIFIESTOS
					   , @ID_TIPO_ENVIO
					   , GETDATE()				
					   , @ID_CASILLERO		
					   , @ID_CUENTA			
					   , @COMENTARIO		
					   , @DESCRIPCION		
					   , @VALOR_DECLARADO)

				SELECT alertaId from [dbo].[ALERTAS_ENVIOS] where alertaId = @@IDENTITY
			RETURN 0
		END

--------------------------------------------------------------------
--	10. Buscar manifiestos sin envio
--------------------------------------------------------------------
		IF @OPERATION = 10
		BEGIN
			SET @ENTRO = 1
						
			IF(@FECHA_FINAL IS NOT NULL)
				SET @FECHA_FINAL =  DATEADD(DAY,1,@FECHA_FINAL)

			SELECT 
				MANIFIESTO.manifiesto_id,
				manifiesto.nrogui,
				fec_recibo,
				pesolb,
				nropaq,
				rem_nombre,
				rem_telefono,
				guimia
			FROM manifiesto 
			LEFT JOIN DETALLECONSOLIDADO 
			ON MANIFIESTO.nrogui = detalleconsolidado.nrogui 
			WHERE ISNULL(DETALLECONSOLIDADO.consolidado_id, 0) = 0  
			AND ISNULL(manifiesto.tipo_Envio, 0) = 0 
			AND ISNULL(fechaanulacion, 0) = 0 
			AND fec_recibo > '2017-01-01' 

			AND casillero_id = @ID_CASILLERO
			AND (@WHR IS NULL OR(@WHR IS NOT NULL AND MANIFIESTO.nrogui = @WHR))
			AND (@NOMBRE IS NULL OR(@NOMBRE IS NOT NULL AND rem_nombre LIKE @NOMBRE))

			AND (@FECHA IS NULL OR(@FECHA IS NOT NULL AND fec_recibo >= @FECHA))
			AND (@FECHA_FINAL IS NULL OR(@FECHA_FINAL IS NOT NULL AND fec_recibo <= @FECHA_FINAL))

			RETURN 0
		END

--------------------------------------------------------------------
--	11. Buscar Ordenes de envio
--------------------------------------------------------------------
		IF @OPERATION = 11
		BEGIN
			SET @ENTRO = 1
						
			IF(@FECHA_FINAL IS NOT NULL)
				SET @FECHA_FINAL =  DATEADD(DAY,1,@FECHA_FINAL)

			SELECT 
				alertaId,				
				alerFecha,
				alerManifId,
				SUBSTRING (SUBSTRING((SELECT nrogui + ', ' AS 'data()' 
						FROM manifiesto  where manifiesto_id in (select item from dbo.Split( alerManifId , ',' ))
						FOR XML PATH('')), 1, 9999), 1, LEN(SUBSTRING((SELECT nrogui + ', ' AS 'data()' 
						FROM manifiesto  where manifiesto_id in (select item from dbo.Split( alerManifId , ',' ))
						FOR XML PATH('')), 1, 9999)) - 1 )	 as WHRs,			
				alerValdec,
				alerDescri,
				alerComentario,
				alerCodTipo,
				desTipo,
				alerCasid
			FROM alertas_envios 
			INNER JOIN casilleros on alerCasid = cas_casillero_id 
			INNER JOIN Tipo_envio on alerCodTipo = CodTipo 
			WHERE 
				alerCasId = @ID_CASILLERO
			AND (@ID_TIPO_ENVIO IS NULL OR(@ID_TIPO_ENVIO IS NOT NULL AND alerCodTipo LIKE @ID_TIPO_ENVIO))

			AND (@FECHA IS NULL OR(@FECHA IS NOT NULL AND alerFecha >= @FECHA))
			AND (@FECHA_FINAL IS NULL OR(@FECHA_FINAL IS NOT NULL AND alerFecha <= @FECHA_FINAL))
			RETURN 0
		END
		
--------------------------------------------------------------------
--	12. Buscar Manifiestos recientes
--------------------------------------------------------------------
		IF @OPERATION = 12
		BEGIN
			SET @ENTRO = 1
			
			SELECT TOP 15 
				manifiesto_id,
				nrogui,
				fec_recibo,
				pesolb,
				nropaq,
				rem_nombre,
				rem_telefono
			FROM dbo.manifiesto 
			WHERE 
				fechaAnulacion IS NULL 
			AND
				casillero_id = @ID_CASILLERO
			ORDER BY fec_recibo DESC

			RETURN 0
		END

--------------------------------------------------------------------
--	13. Buscar Manifiestos 
--------------------------------------------------------------------
		IF @OPERATION = 13
		BEGIN
			SET @ENTRO = 1
			
			IF(@FECHA_FINAL IS NOT NULL)
				SET @FECHA_FINAL =  DATEADD(DAY,1,@FECHA_FINAL)

			SELECT
				manifiesto_id,
				nrogui,
				fec_recibo,
				pesolb,
				nropaq,
				rem_nombre,
				rem_telefono,
				--total
				(isnull(impuestos,0) + isnull(fijoffw,0) + isnull(fijoagencia,0) + isnull(otros,0) + isnull(adicionales,0) + isnull(flete,0) + isnull(seguroffw,0) + isnull(seguroAgencia,0)) - isnull(descuento,0) as total
			FROM dbo.manifiesto 
			WHERE 
				casillero_id = @ID_CASILLERO

			AND (@WHR IS NULL OR(@WHR IS NOT NULL AND MANIFIESTO.nrogui = @WHR))
			AND (@GUIMIA IS NULL OR(@GUIMIA IS NOT NULL AND MANIFIESTO.guimia = @GUIMIA))
			AND (@NOMBRE IS NULL OR(@NOMBRE IS NOT NULL AND rem_nombre LIKE @NOMBRE))
			AND (@TELEFONO IS NULL OR(@TELEFONO IS NOT NULL AND rem_telefono LIKE @TELEFONO))
			AND (@FECHA IS NULL OR(@FECHA IS NOT NULL AND fec_recibo >= @FECHA))
			AND (@FECHA_FINAL IS NULL OR(@FECHA_FINAL IS NOT NULL AND fec_recibo <= @FECHA_FINAL))


			ORDER BY fec_recibo DESC

			RETURN 0
		END

--------------------------------------------------------------------
--	14. Obtener ciudades
--------------------------------------------------------------------
		IF @OPERATION = 14
		BEGIN
			SET @ENTRO = 1
			
			SELECT
				id_ciudad,
				c.nombre as nomCiudad
				--c.id_pais as id_pais,
				--p.codigo as codPais,				
				--c.estado as nomEstado,
				--p.nombre as nomPais
			FROM dbo.CIUDADES as c  			
			WHERE 
					c.id_pais = @ID
				AND c.estado =  @NOMBRE
			ORDER BY c.nombre

			RETURN 0
		END

--------------------------------------------------------------------
--	15. Obtener plantilla correo
--------------------------------------------------------------------
		IF @OPERATION = 15
		BEGIN
			SET @ENTRO = 1
			
			SELECT TOP 1
				TE_NAME,
				TE_SUBJECT,
				TE_BODY 
			FROM template_emails 
			WHERE 
				TE_NAME = @NOMBRE 
			AND TE_DESABILITADO is null

			RETURN 0
		END

--------------------------------------------------------------------
--	16. Obtener total debido
--------------------------------------------------------------------
		IF @OPERATION = 16
		BEGIN
			SET @ENTRO = 1
			
			SELECT 
				--ISNULL(SUM(total),0) as Total
				ISNULL(SUM((isnull(impuestos,0) + isnull(fijoffw,0) + isnull(fijoagencia,0) + isnull(otros,0) + isnull(adicionales,0) + isnull(flete,0) + isnull(seguroffw,0) + isnull(seguroAgencia,0)) - isnull(descuento,0)),0) as Total
			FROM manifiesto 
			WHERE 
				casillero_id = @ID_CASILLERO	
			AND fechaAnulacion IS NULL 
			AND pagado IS NULL

			RETURN 0
		END

--------------------------------------------------------------------
--	17. Consultar Compania
--------------------------------------------------------------------
		IF @OPERATION = 17
		BEGIN
			SET @ENTRO = 1
			
			SELECT TOP 1
				nombre,
				direccion,
				ciudad,
				estado,
				pais,
				zip,
				telefono
			FROM ffw 
			ORDER BY FFW ASC

			RETURN 0
		END

--------------------------------------------------------------------
--	18. Detalle manifiesto
--------------------------------------------------------------------
		IF @OPERATION = 18
		BEGIN
			SET @ENTRO = 1
			
			SELECT 
				manifiesto.manifiesto_id as manifiesto_id
				-- cas_pago,
				,crt_descripcion as CrtDescripcion
				,cas_servicio as CasilleroServicio
				,cas_casillero as NumeroCasillero
				,cas_alias as Alias
				,manifiesto.nrogui as NumeroGuia
				,manifiesto.fec_recibo as FechaRecibo
				,manifiesto.agencia as Agencia
				,manifiesto.guimia as Guimia
				,manifiesto.pesolb as PesoLb
				,manifiesto.impuestos as Impuestos
				,manifiesto.valordeclarado as ValorDeclarado
				,manifiesto.nropaq as Pieces
				,manifiesto.peso_real as PesoReal
				,manifiesto.seguroffw
				,manifiesto.seguroagencia			
				,manifiesto.flete
				,manifiesto.pagado
				--,manifiesto.total
				,(isnull(impuestos,0) + isnull(fijoffw,0) + isnull(fijoagencia,0) + isnull(otros,0) + isnull(adicionales,0) + isnull(flete,0) + isnull(seguroffw,0) + isnull(seguroAgencia,0)) - isnull(descuento,0) as total
				,manifiesto.fechaanulacion
				,remitente.nombre as NombreRemitente
				,remitente.direccion as DireccionRemitente
				,remitente.ciudad as CiudadRemitente
				,remitente.pais as PaisRemitente
				,remitente.estado as EstadoRemitente
				,remitente.zip as ZipRemitente
				,remitente.telefono as TelefonoRemitente
				,DESTINATARIO.nombre as NombreDest
				,DESTINATARIO.direccion as DireccionDest
				,DESTINATARIO.zip as  ZipDest
				,DESTINATARIO.telefono as TelefonoDest
				,CIUDADES.nombre as CiudadDest
				,CIUDADES.estado as EstadoDest
				,PAISES.nombre as PaisDest
				,AGENCIAS.nombre as NombreAgencia
				,AGENCIAS.direccion1 as DireccionAgencia
				,AGENCIAS.telefono as TelefonoAgencia
				,CUENTAS.empresa + ' - ' + CUENTAS.nombre as cuenta
				,usuarios.nombre as Cajero
				,manifiesto.moneda as strCurrency
				,manifiesto.descri as descripcion

			FROM dbo.manifiesto 			   
			left outer join usuarios on usuarios.id_usuario = manifiesto.codemp    
			inner join remitente on remitente.n_remitente = manifiesto.n_remitente   
			inner join DESTINATARIO 
				on DESTINATARIO.n_beneficiario = manifiesto.n_beneficiario 
				and DESTINATARIO.n_remitente = manifiesto.n_remitente   

			inner join CIUDADES on manifiesto.id_ciudad = CIUDADES.id_ciudad  
			inner join paises on ciudades.id_pais=paises.id_pais 

			inner join AGENCIAS 
				on AGENCIAS.agencia = manifiesto.agencia 
				and AGENCIAS.ffw=manifiesto.ffw  
			left outer join CUENTAS on manifiesto.cuenta_id = CUENTAS.cuenta_id 
			left outer join casilleros on cas_casillero_id= manifiesto.casillero_id  
			left outer join codigos_retencion on crt_codigo_retencion_id = codigo_retencion_id 
			
			WHERE 
				manifiesto_id = @ID_MANIFIESTO
			and 
				manifiesto.casillero_id = @ID_CASILLERO

			--	select * from DESTINATARIO

			RETURN 0
		END

--------------------------------------------------------------------
--	19. Status
--------------------------------------------------------------------
		IF @OPERATION = 19
		BEGIN
			SET @ENTRO = 1
			--select * from status
			SELECT 
				fecreal
				,comentarios
				--,status.* ,
				,tipstatus.dessta as descri  
			FROM dbo.status  
			inner join manifiesto 
				on  manifiesto.ffw = status.ffw 
				and  manifiesto.nrogui = status.nrogui  
			inner join tipstatus 
				on  status.codsta = tipstatus.codsta 
				and  status.ffw = tipstatus.ffw 
				and tipstatus.publico = 1 
			WHERE 
				manifiesto.manifiesto_id = @ID_MANIFIESTO
			ORDER BY 
				status.fecreal desc

			RETURN 0
		END
		
--------------------------------------------------------------------
--	20. Adjuntos
--------------------------------------------------------------------
		IF @OPERATION = 20
		BEGIN
			SET @ENTRO = 1
			
			SELECT
				 paq_alto
				,paq_largo
				,paq_ancho
				,paq_volumen
				,paq_peso
				,paq_nrogui
			FROM dbo.PAQADJUNTOS  
			WHERE 
				paq_manifiesto_id = @ID_MANIFIESTO

			RETURN 0
		END

--------------------------------------------------------------------
--	21. Contenido
--------------------------------------------------------------------
		IF @OPERATION = 21
		BEGIN
			SET @ENTRO = 1
			
			SELECT 
				 cnt_detalle
				,cnt_cantidad
				,cnt_nrogui
			FROM contenido 
			WHERE cnt_manifiesto_id = @ID_MANIFIESTO

			RETURN 0
		END

--------------------------------------------------------------------
--	22. Archivo Adjunto detalle
--------------------------------------------------------------------
		IF @OPERATION = 22
		BEGIN
			SET @ENTRO = 1
			
			SELECT  
				 ARC_ARCHIVO_ID
				,ARC_NOMBRE
				,ARC_PATH
			FROM ARCHIVOS 
			WHERE 
				ARC_MANIFIESTO_ID= @ID_MANIFIESTO

			RETURN 0
		END
		
--------------------------------------------------------------------
--	23. Cobros adicionales
--------------------------------------------------------------------
		IF @OPERATION = 23
		BEGIN
			SET @ENTRO = 1
			
			SELECT 
				cca_concepto_cobro_adicional_id as cId,
				cag_valor as valor,
				SUM(cag_valor) as total,				
				cca_concepto as concepto, 
				COUNT(cca_concepto) as cantidad 
			FROM 
				cobros_adicionales_guias 
			INNER JOIN conceptos_cobros_adicionales ON 	cca_concepto_cobro_adicional_id = cag_concepto_cobro_adicional_id 
			WHERE 
				cag_manifiesto_id = @ID_MANIFIESTO			
			GROUP BY 
				cca_concepto_cobro_adicional_id,
				cca_concepto,cag_valor


			RETURN 0
		END


--------------------------------------------------------------------
--	24. Paises
--------------------------------------------------------------------
		IF @OPERATION = 24
		BEGIN
			SET @ENTRO = 1
			
			SELECT 
				id_pais,
				nombre,
				codigo
			FROM paises
			where id_pais in (select distinct id_pais from CIUDADES)
			ORDER BY nombre asc

			RETURN 0
		END

--------------------------------------------------------------------
--	25. Estados pais
--------------------------------------------------------------------
		IF @OPERATION = 25
		BEGIN
			SET @ENTRO = 1
						
			SELECT DISTINCT ESTADO FROM CIUDADES WHERE ID_PAIS = @ID

			RETURN 0
		END

--------------------------------------------------------------------
--	26. Buscar Manifiestos para pagar
--------------------------------------------------------------------
		IF @OPERATION = 26
		BEGIN
			SET @ENTRO = 1
			
			IF(@FECHA_FINAL IS NOT NULL)
				SET @FECHA_FINAL =  DATEADD(DAY,1,@FECHA_FINAL)

			--1. Se busca la TRM activa 
			declare  @FACTOR decimal = null

			-- El pago siempre se realiza en pesos colombianos 
			--SELECT TOP 1 
			--	@FACTOR = factor
			--FROM 
			--	TRM_CONVERSION
			--INNER JOIN 
			--	MONEDAS ORIGEN ON ORIGEN.MON_MONEDA_ID = TRM_CONVERSION.ID_MONEDA_ORIGEN
			--INNER JOIN 
			--	MONEDAS DESTINO ON DESTINO.MON_MONEDA_ID = TRM_CONVERSION.ID_MONEDA_DESTINO
			--WHERE
			-- ORIGEN.MON_SIMBOLO = @MONEDA_ORIGEN AND
			-- DESTINO.MON_NOMBRE = 'Peso Colombiano' 
			--ORDER BY TRM_CONVERSION.FECHA DESC

			--if @FACTOR is null set @FACTOR = 0

			-- Se buscan las guias y se convierte las que vienen en COP 
			SELECT 
				manifiesto_id,
				nrogui,
				fec_recibo,
				pesolb,
				nropaq,
				rem_nombre,
				rem_telefono,
				--total
				(isnull(impuestos,0) + isnull(fijoffw,0) + isnull(fijoagencia,0) + isnull(otros,0) + isnull(adicionales,0) + isnull(flete,0) + isnull(seguroffw,0) + isnull(seguroAgencia,0)) - isnull(descuento,0) as total
				, moneda AS Currency
				, CASE WHEN MONEDA = '$' THEN				
				 (((isnull(impuestos,0) + isnull(fijoffw,0) + isnull(fijoagencia,0) + isnull(otros,0) + isnull(adicionales,0) + isnull(flete,0) + isnull(seguroffw,0) + isnull(seguroAgencia,0)) - isnull(descuento,0))
				   * 
				   --Buscar TRM
						( SELECT TOP 1 
							isnull(factor,0)
						FROM 
							TRM_CONVERSION
						INNER JOIN 
							MONEDAS ORIGEN ON ORIGEN.MON_MONEDA_ID = TRM_CONVERSION.ID_MONEDA_ORIGEN
						INNER JOIN 
							MONEDAS DESTINO ON DESTINO.MON_MONEDA_ID = TRM_CONVERSION.ID_MONEDA_DESTINO
						WHERE
						 ORIGEN.MON_SIMBOLO = moneda AND
						 (DESTINO.MON_NOMBRE = 'Peso Colombiano'  or DESTINO.MON_NOMBRE = 'Pesos Colombianos' or DESTINO.MON_NOMBRE = 'PESOS' )
						ORDER BY TRM_CONVERSION.FECHA DESC)
				   )				   
				--   @FACTOR )
				   ELSE
				    ((isnull(impuestos,0) + isnull(fijoffw,0) + isnull(fijoagencia,0) + isnull(otros,0) + isnull(adicionales,0) + isnull(flete,0) + isnull(seguroffw,0) + isnull(seguroAgencia,0)) - isnull(descuento,0))
					end
				  as totalCOP
				  ,--@FACTOR  as TRM -- Se envia TRM para mostrar en pantalla, no se relaciona con la guia
				  ( SELECT TOP 1 
							isnull(factor,0)
						FROM 
							TRM_CONVERSION
						INNER JOIN 
							MONEDAS ORIGEN ON ORIGEN.MON_MONEDA_ID = TRM_CONVERSION.ID_MONEDA_ORIGEN
						INNER JOIN 
							MONEDAS DESTINO ON DESTINO.MON_MONEDA_ID = TRM_CONVERSION.ID_MONEDA_DESTINO
						WHERE
						 ORIGEN.MON_SIMBOLO = moneda AND
						 (DESTINO.MON_NOMBRE = 'Peso Colombiano'  or DESTINO.MON_NOMBRE = 'Pesos Colombianos'  or DESTINO.MON_NOMBRE = 'PESOS')
						ORDER BY TRM_CONVERSION.FECHA DESC)  as TRM 
			FROM dbo.manifiesto 
			WHERE 
				fechaanulacion is null
			AND casillero_id =  @ID_CASILLERO
			AND (isnull(impuestos,0) + isnull(fijoffw,0) + isnull(fijoagencia,0) + isnull(otros,0) + isnull(adicionales,0) + isnull(flete,0) + isnull(seguroffw,0) + isnull(seguroAgencia,0)) - isnull(descuento,0) > 0
			and pagado is null

			AND (@WHR IS NULL OR(@WHR IS NOT NULL AND MANIFIESTO.nrogui = @WHR))
			AND (@GUIMIA IS NULL OR(@GUIMIA IS NOT NULL AND MANIFIESTO.guimia = @GUIMIA))
			AND (@NOMBRE IS NULL OR(@NOMBRE IS NOT NULL AND rem_nombre LIKE @NOMBRE))
			AND (@TELEFONO IS NULL OR(@TELEFONO IS NOT NULL AND rem_telefono LIKE @TELEFONO))
			AND (@FECHA IS NULL OR(@FECHA IS NOT NULL AND fec_recibo >= @FECHA))
			AND (@FECHA_FINAL IS NULL OR(@FECHA_FINAL IS NOT NULL AND fec_recibo <= @FECHA_FINAL))

			and total > 0

			--Se buscan las guias que no esten pendientes de pago
			and manifiesto.manifiesto_id not in (SELECT ID_GUIA FROM PENDIENTES_PAGO_GUIAS_CASILLERO)

			ORDER BY fec_recibo DESC

			RETURN 0
		END


--------------------------------------------------------------------
--	27. Recordar contraseña por email
--------------------------------------------------------------------
		IF @OPERATION = 27
		BEGIN
			SET @ENTRO = 1
			
			 SELECT top 1
				[cas_casillero_id]				  
			 FROM CASILLEROS 
			 WHERE 
				cas_email = @EMAIL  

			RETURN 0
		END

--------------------------------------------------------------------
--	28. Recordar contraseña por numero casillero
--------------------------------------------------------------------
		IF @OPERATION = 28
		BEGIN
			SET @ENTRO = 1
			
			 SELECT 
				[cas_casillero_id]				  
			 FROM CASILLEROS 
			 WHERE 
				cas_casillero = @cas_casillero
				
			RETURN 0
		END

--------------------------------------------------------------------
--	29. INSERTAR GUIAS PENDIETES DE PAGO
--------------------------------------------------------------------
		IF @OPERATION = 29
		BEGIN
			SET @ENTRO = 1
			
			
			INSERT INTO [dbo].[PENDIENTES_PAGO_GUIAS_CASILLERO]          
				  ([ID_PAGO]
				   ,[ID_GUIA]
				   ,[FECHA])
			 VALUES
				  (
				    @ID_PAGO
				   ,@ID_MANIFIESTO
				   ,GETDATE())
			RETURN 0
		END


--------------------------------------------------------------------
--	30. BORRAR GUIAS PENDIENTES DE PAGO (CUADNO SE EFECTUA EL PAGO O EXPIRA LA FECHA DE PAGO)
--------------------------------------------------------------------
		IF @OPERATION = 30
		BEGIN
			SET @ENTRO = 1
			
				DELETE FROM [dbo].[PENDIENTES_PAGO_GUIAS_CASILLERO]
					  WHERE [PENDIENTES_PAGO_GUIAS_CASILLERO].ID_GUIA = @ID_MANIFIESTO
				
			RETURN 0
		END
		

--------------------------------------------------------------------
--	31. INSERT PAGO GUIAS CB1
--------------------------------------------------------------------
		IF @OPERATION = 31
		BEGIN
			SET @ENTRO = 1										
								
				INSERT INTO pago_guias 
					(pgu_manifiesto_id,
					 pgu_fecha,
					 pgu_usuario_id,
					 pgu_monto,
				 	 pgu_forma_pago,
					 pgu_comentario,
					 pgu_factura) 
					VALUES (
					@ID_MANIFIESTO,
					GETDATE(),
					1, --USUARIO
					@VALOR,
					@FORMA_PAGO,
					@COMENTARIO,
					@ID)		

			-- DESPUES DE REALIZAR EL PAGO DE LAS GUIAS SE COLOCA EL ESTADO DE AUTORIZADO

				-- SE DECLARA LA VARIABLE DE AUTORIZADO, LA CUAL SERA USADA EN ESTA OPERACION
				DECLARE @CODSTA_AUTORIZA	 INT		 =  0
				-- SE OBTIENE EL CODIGO DE ESTADO AUTORIZADO DE LA TABLA CONFIG PARA HACER EL INSERT DE STATUS							
				SELECT @CODSTA_AUTORIZA = CFG_AUTORIZAR FROM CONFIG
				-- SE OBTIENE EL VALOR DEL FFW DE LA TABLA FFW
				SELECT @FFW = ffw FROM FFW
				-- SE OBTIENE EL VALOR DEL NUMERO DE GUIA DE LA TABLA MANIFIESTO
				SELECT @WHR = nrogui FROM MANIFIESTO WHERE manifiesto_id=@ID_MANIFIESTO
				
				INSERT INTO STATUS 
					(FFW,
					 nrogui,
					 codsta,
					 fecha,
					 fecreal,
					 id_usuario) 
					VALUES (
					@FFW,
					@WHR,
					@CODSTA_AUTORIZA,
					GETDATE(),
					GETDATE(),
					1) --USUARIO
						

				
			RETURN 0
		END

--------------------------------------------------------------------
--	32. Elimina una alerta
--------------------------------------------------------------------
		IF @OPERATION = 32
		BEGIN
			SET @ENTRO = 1
			
				DELETE FROM [dbo].[ALERTAS]
					  WHERE [ALERTAS].alr_alerta_id = @ID

					  if exists (SELECT ALR_ALERTA_ID FROM ALERTAS WHERE [ALERTAS].alr_alerta_id = @ID)
					  select 1
					  else
					  select 0
		END
--------------------------------------------------------------------
-- 33. Consulta Pago Guia temporal.
--------------------------------------------------------------------
		IF @OPERATION = 33
		BEGIN
			SET @ENTRO = 1

				SELECT 
					pgu_manifiesto_id,
					pgu_usuario_id,
					pgu_monto,
					pgu_forma_pago,
					pgu_comentario,
					pgu_pago_guia_id,
					pgu_factura
				FROM 
				dbo.PAGO_GUIAS_PENDIENTES
				WHERE PGU_MANIFIESTO_ID = @ID_MANIFIESTO
		END
--------------------------------------------------------------------
-- 34. Retorna el id de manifiesto buscando por key
--------------------------------------------------------------------
		IF @OPERATION = 34
		BEGIN
			SET @ENTRO = 1
			DECLARE @RETORNO INT = 0
				
			SET @RETORNO = (SELECT
					MANIFIESTO_ID
				FROM
				dbo.PAGO_KEY 
				WHERE GUIA_KEY = @GUIA_KEY)

			SELECT ISNULL(@RETORNO, 0) AS MANIFIESTO_ID
		END
--------------------------------------------------------------------
--	35. Detalle manifiesto
--------------------------------------------------------------------
		IF @OPERATION = 35
		BEGIN
			SET @ENTRO = 1
			
			SELECT 
				manifiesto.manifiesto_id as manifiesto_id
				-- cas_pago,
				,crt_descripcion as CrtDescripcion
				,cas_servicio as CasilleroServicio
				,cas_casillero as NumeroCasillero
				,cas_alias as Alias
				,manifiesto.nrogui as NumeroGuia
				,manifiesto.fec_recibo as FechaRecibo
				,manifiesto.agencia as Agencia
				,manifiesto.guimia as Guimia
				,manifiesto.pesolb as PesoLb
				,manifiesto.impuestos as Impuestos
				,manifiesto.valordeclarado as ValorDeclarado
				,manifiesto.nropaq as Pieces
				,manifiesto.peso_real as PesoReal
				,manifiesto.seguroffw
				,manifiesto.seguroagencia			
				,manifiesto.flete
				,manifiesto.pagado
				--,manifiesto.total
				,(isnull(impuestos,0) + isnull(fijoffw,0) + isnull(fijoagencia,0) + isnull(otros,0) + isnull(adicionales,0) + isnull(flete,0) + isnull(seguroffw,0) + isnull(seguroAgencia,0)) - isnull(descuento,0) as total
				,manifiesto.fechaanulacion
				,remitente.nombre as NombreRemitente
				,remitente.direccion as DireccionRemitente
				,remitente.ciudad as CiudadRemitente
				,remitente.pais as PaisRemitente
				,remitente.estado as EstadoRemitente
				,remitente.zip as ZipRemitente
				,remitente.telefono as TelefonoRemitente
				,DESTINATARIO.nombre as NombreDest
				,DESTINATARIO.direccion as DireccionDest
				,DESTINATARIO.zip as  ZipDest
				,DESTINATARIO.telefono as TelefonoDest
				,CIUDADES.nombre as CiudadDest
				,CIUDADES.estado as EstadoDest
				,PAISES.nombre as PaisDest
				,AGENCIAS.nombre as NombreAgencia
				,AGENCIAS.direccion1 as DireccionAgencia
				,AGENCIAS.telefono as TelefonoAgencia
				,CUENTAS.empresa + ' - ' + CUENTAS.nombre as cuenta
				,usuarios.nombre as Cajero
				,manifiesto.moneda as strCurrency
				,manifiesto.descri as descripcion,
				( SELECT TOP 1 
							isnull(factor,0)
						FROM 
							TRM_CONVERSION
						INNER JOIN 
							MONEDAS ORIGEN ON ORIGEN.MON_MONEDA_ID = TRM_CONVERSION.ID_MONEDA_ORIGEN
						INNER JOIN 
							MONEDAS DESTINO ON DESTINO.MON_MONEDA_ID = TRM_CONVERSION.ID_MONEDA_DESTINO
						WHERE
						 ORIGEN.MON_SIMBOLO = moneda AND
						 (DESTINO.MON_NOMBRE = 'Peso Colombiano'  or DESTINO.MON_NOMBRE = 'Pesos Colombianos'  or DESTINO.MON_NOMBRE = 'PESOS')
						ORDER BY TRM_CONVERSION.FECHA DESC)  as TRM, 
						CASE WHEN MONEDA = '$' THEN				
						 (((isnull(impuestos,0) + isnull(fijoffw,0) + isnull(fijoagencia,0) + isnull(otros,0) + isnull(adicionales,0) + isnull(flete,0) + isnull(seguroffw,0) + isnull(seguroAgencia,0)) - isnull(descuento,0))
						   * 
						   --Buscar TRM
								( SELECT TOP 1 
									isnull(factor,0)
								FROM 
									TRM_CONVERSION
								INNER JOIN 
									MONEDAS ORIGEN ON ORIGEN.MON_MONEDA_ID = TRM_CONVERSION.ID_MONEDA_ORIGEN
								INNER JOIN 
									MONEDAS DESTINO ON DESTINO.MON_MONEDA_ID = TRM_CONVERSION.ID_MONEDA_DESTINO
								WHERE
								 ORIGEN.MON_SIMBOLO = moneda AND
								 (DESTINO.MON_NOMBRE = 'Peso Colombiano'  or DESTINO.MON_NOMBRE = 'Pesos Colombianos'  or DESTINO.MON_NOMBRE = 'PESOS')
								ORDER BY TRM_CONVERSION.FECHA DESC)
						   )				   
						--   @FACTOR )
						   ELSE
							((isnull(impuestos,0) + isnull(fijoffw,0) + isnull(fijoagencia,0) + isnull(otros,0) + isnull(adicionales,0) + isnull(flete,0) + isnull(seguroffw,0) + isnull(seguroAgencia,0)) - isnull(descuento,0))
							end
						  as totalCOP

			FROM dbo.manifiesto 			   
			left outer join usuarios on usuarios.id_usuario = manifiesto.codemp    
			inner join remitente on remitente.n_remitente = manifiesto.n_remitente   
			inner join DESTINATARIO 
				on DESTINATARIO.n_beneficiario = manifiesto.n_beneficiario 
				and DESTINATARIO.n_remitente = manifiesto.n_remitente   

			inner join CIUDADES on manifiesto.id_ciudad = CIUDADES.id_ciudad  
			inner join paises on ciudades.id_pais=paises.id_pais 

			inner join AGENCIAS 
				on AGENCIAS.agencia = manifiesto.agencia 
				and AGENCIAS.ffw=manifiesto.ffw  
			left outer join CUENTAS on manifiesto.cuenta_id = CUENTAS.cuenta_id 
			left outer join casilleros on cas_casillero_id=manifiesto.casillero_id 
			left outer join codigos_retencion on crt_codigo_retencion_id = codigo_retencion_id 
			
			WHERE 
				manifiesto_id = @ID_MANIFIESTO			

			RETURN 0
		END
--------------------------------------------------------------------
--	36. Borrar Key pago COD
--------------------------------------------------------------------
		IF @OPERATION = 36
		BEGIN
			SET @ENTRO = 1
			
			DELETE PAGO_KEY WHERE MANIFIESTO_ID = @ID_MANIFIESTO

		END
--------------------------------------------------------------------


		IF @ENTRO = 0
			RAISERROR ('Operacion no soportada por el procedimiento.', 16, 1);
		ELSE
			RETURN @@ERROR
END

/*********************************************************************/


