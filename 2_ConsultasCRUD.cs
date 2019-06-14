using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Entidades;
using System.Data.SqlClient;

namespace Data
{
    public class ConsultasCRUD : Conexion
    {
        public Template ObtenerPlantilla(string nombre)
        {
            SqlCommand sqlcommand = GetSqlCommandInstance(ProcedimientosAlmacenados.Consultas);
            sqlcommand.Parameters.AddWithValue(Parametros.Nombre, nombre);
            sqlcommand.Parameters.AddWithValue(Parametros.Operation, 15);

            Template plantilla = new Template();

            using (SqlDataReader reader = sqlcommand.ExecuteReader())
            {
                while (reader.Read())
                {
                    plantilla.Name = (string)reader["TE_NAME"];
                    plantilla.Subject = (string)reader["TE_SUBJECT"];
                    plantilla.Body = (string)reader["TE_BODY"];
                }
            }
            DisposeCommand(sqlcommand);
            return plantilla;
        }

        public Service ObtenerServicio()
        {
            SqlCommand sqlcommand = GetSqlCommandInstance(ProcedimientosAlmacenados.Consultas);

            sqlcommand.Parameters.AddWithValue(Parametros.Operation, 5);

            Service servicio = new Service();

            using (SqlDataReader reader = sqlcommand.ExecuteReader())
            {
                while (reader.Read())
                {
                    servicio.IdProduct = (int)reader["CFG_PRODUCTOCASILLERO"];
                    servicio.Name = (string)reader["NOMBRE"];
                    servicio.IsPoBoxAgent = (int)reader["CFG_AGEN_CASI"];
                }
            }
            DisposeCommand(sqlcommand);
            return servicio;
        }

        public List<Agent> ObtenerAgencias(string ffw)
        {
            // rsAgencias.Source = "SELECT *  FROM dbo.AGENCIAS  WHERE ffw='" + Replace(rsAgencias__tmpffw, "'", "''") + "'  ORDER BY nombre"
            return null;
        }

        #region Ordenes de envio

        public List<ShipmentType> ObtenerTiposEnvio()
        {
            SqlCommand sqlcommand = GetSqlCommandInstance(ProcedimientosAlmacenados.Consultas);

            sqlcommand.Parameters.AddWithValue(Parametros.Operation, 7);

            List<ShipmentType> tiposEnvio = new List<ShipmentType>();
            ShipmentType tipo = null;

            using (SqlDataReader reader = sqlcommand.ExecuteReader())
            {
                while (reader.Read())
                {
                    tipo = new ShipmentType();
                    tipo.Code = (int)reader["CODTIPO"];
                    tipo.Name = (string)reader["DESTIPO"];
                    tiposEnvio.Add(tipo);
                }
            }
            DisposeCommand(sqlcommand);

            return tiposEnvio;
        }

        public List<Waybill> BuscarManifiestosSinAlerta(Filter filtro)
        {

            SqlCommand sqlcommand = GetSqlCommandInstance(ProcedimientosAlmacenados.Consultas);

            sqlcommand.Parameters.AddWithValue(Parametros.IdCasillero, filtro.IdPobox);

            if (!string.IsNullOrEmpty(filtro.Waybill))
                sqlcommand.Parameters.AddWithValue(Parametros.WHR, filtro.Waybill);
            if (!string.IsNullOrEmpty(filtro.SenderName))
                sqlcommand.Parameters.AddWithValue(Parametros.Nombre, filtro.SenderName);
            if (filtro.InitialDate.HasValue)
                sqlcommand.Parameters.AddWithValue(Parametros.Fecha, filtro.InitialDate.Value);
            if (filtro.FinalDate.HasValue)
                sqlcommand.Parameters.AddWithValue(Parametros.FechaFinal, filtro.FinalDate.Value);

            sqlcommand.Parameters.AddWithValue(Parametros.Operation, 10);

            List<Waybill> manifiestos = new List<Waybill>();
            Waybill manifiesto = null;

            using (SqlDataReader reader = sqlcommand.ExecuteReader())
            {
                while (reader.Read())
                {
                    manifiesto = new Waybill();
                    manifiesto.Id = (int)reader["manifiesto_id"];
                    manifiesto.WaybillNumber = (string)reader["nrogui"];
                    manifiesto.ReceiptDate = (DateTime)reader["fec_recibo"];
                    manifiesto.WeightLB = (decimal)reader["pesolb"];
                    manifiesto.Pieces = (int)reader["nropaq"];
                    manifiesto.SenderName = (string)reader["rem_nombre"];
                    manifiesto.SenderPhone = (string)reader["rem_telefono"];

                    manifiestos.Add(manifiesto);

                }
            }
            DisposeCommand(sqlcommand);

            return manifiestos;
        }

        public void AplicarTipoEnvio(int idManifiesto, int idTipoEnvio, bool esUltimoEnvio)
        {
            SqlCommand sqlcommand = GetSqlCommandInstance(ProcedimientosAlmacenados.Consultas);

            sqlcommand.Parameters.AddWithValue(Parametros.IdTipoEnvio, idTipoEnvio);
            sqlcommand.Parameters.AddWithValue(Parametros.UltimoEnvio, esUltimoEnvio);
            sqlcommand.Parameters.AddWithValue(Parametros.IdManifiesto, idManifiesto);

            sqlcommand.Parameters.AddWithValue(Parametros.Operation, 8);


            ScalarSQLCommand(sqlcommand);
        }

        public int CrearAlertaEnvio(OrderShipment alerta)
        {
            SqlCommand sqlcommand = GetSqlCommandInstance(ProcedimientosAlmacenados.Consultas);

            sqlcommand.Parameters.AddWithValue(Parametros.IdsManifiestos, alerta.IdsWaybills);
            sqlcommand.Parameters.AddWithValue(Parametros.IdTipoEnvio, alerta.ShipmentType.Code);
            sqlcommand.Parameters.AddWithValue(Parametros.IdCasillero, alerta.IdPoBox);
            sqlcommand.Parameters.AddWithValue(Parametros.IdCuenta, alerta.IdAccount);
            sqlcommand.Parameters.AddWithValue(Parametros.Comentario, alerta.Comment);
            sqlcommand.Parameters.AddWithValue(Parametros.Descripcion, alerta.Description);
            sqlcommand.Parameters.AddWithValue(Parametros.ValorDeclarado, alerta.DeclaredValue);

            sqlcommand.Parameters.AddWithValue(Parametros.Operation, 9);

            return (int)ScalarSQLCommand(sqlcommand);

        }

        public List<OrderShipment> BuscarAlertasOrdenesEnvio(Filter filtro)
        {
            SqlCommand sqlcommand = GetSqlCommandInstance(ProcedimientosAlmacenados.Consultas);

            sqlcommand.Parameters.AddWithValue(Parametros.IdCasillero, filtro.IdPobox);

            if (filtro.IdShipmetType > 0)
                sqlcommand.Parameters.AddWithValue(Parametros.IdTipoEnvio, filtro.IdShipmetType);
            if (filtro.InitialDate.HasValue)
                sqlcommand.Parameters.AddWithValue(Parametros.Fecha, filtro.InitialDate.Value);
            if (filtro.FinalDate.HasValue)
                sqlcommand.Parameters.AddWithValue(Parametros.FechaFinal, filtro.FinalDate.Value);

            sqlcommand.Parameters.AddWithValue(Parametros.Operation, 11);

            List<OrderShipment> alertas = new List<OrderShipment>();
            OrderShipment alerta = null;

            using (SqlDataReader reader = sqlcommand.ExecuteReader())
            {
                while (reader.Read())
                {
                    alerta = new OrderShipment();
                    alerta.Id = (int)reader["alertaId"];
                    alerta.Date = reader.IsDBNull(reader.GetOrdinal("alerFecha")) ? new DateTime() : (DateTime)reader["alerFecha"];
                    alerta.IdsWaybills = reader.IsDBNull(reader.GetOrdinal("alerManifId")) ? string.Empty : (string)reader["alerManifId"];
                    alerta.WaybillNumbers = reader.IsDBNull(reader.GetOrdinal("WHRs")) ? string.Empty : (string)reader["WHRs"];
                    alerta.DeclaredValue = reader.IsDBNull(reader.GetOrdinal("alerValdec")) ? 0 : (decimal)reader["alerValdec"];
                    alerta.Description = reader.IsDBNull(reader.GetOrdinal("alerDescri")) ? string.Empty : (string)reader["alerDescri"];
                    alerta.Comment = reader.IsDBNull(reader.GetOrdinal("alerComentario")) ? string.Empty : (string)reader["alerComentario"];
                    alerta.ShipmentType = new ShipmentType()
                    {
                        Code = reader.IsDBNull(reader.GetOrdinal("alerCodTipo")) ? 0 : (int)reader["alerCodTipo"],
                        Name = reader.IsDBNull(reader.GetOrdinal("desTipo")) ? string.Empty : (string)reader["desTipo"]
                    };

                    alertas.Add(alerta);

                }
            }
            DisposeCommand(sqlcommand);

            return alertas;
        }

        #endregion

        #region Consultas globales

        public List<Country> ObtenerPaises()
        {
            SqlCommand sqlcommand = GetSqlCommandInstance(ProcedimientosAlmacenados.Consultas);

            sqlcommand.Parameters.AddWithValue(Parametros.Operation, 24);

            List<Country> paises = new List<Country>();
            Country pais = null;

            using (SqlDataReader reader = sqlcommand.ExecuteReader())
            {
                while (reader.Read())
                {
                    pais = new Country();
                    pais.Id = reader.IsDBNull(reader.GetOrdinal("id_pais")) ? 0 : (int)reader["id_pais"];
                    pais.Code = reader.IsDBNull(reader.GetOrdinal("codigo")) ? string.Empty : (string)reader["codigo"];
                    pais.Name = reader.IsDBNull(reader.GetOrdinal("nombre")) ? string.Empty : (string)reader["nombre"];
                    paises.Add(pais);
                }
            }
            DisposeCommand(sqlcommand);

            return paises;
        }

        public List<State> ObtenerEstados(int idPais)
        {
            SqlCommand sqlcommand = GetSqlCommandInstance(ProcedimientosAlmacenados.Consultas);

            sqlcommand.Parameters.AddWithValue(Parametros.Id, idPais);
            sqlcommand.Parameters.AddWithValue(Parametros.Operation, 25);

            List<State> states = new List<State>();
            State state = null;

            using (SqlDataReader reader = sqlcommand.ExecuteReader())
            {
                while (reader.Read())
                {
                    state = new State();
                    state.Name = reader.IsDBNull(reader.GetOrdinal("ESTADO")) ? string.Empty : (string)reader["ESTADO"];
                    states.Add(state);
                }
            }
            DisposeCommand(sqlcommand);

            return states;
        }

        public List<City> ObtenerCiudades(string nombreEstado, int idPais)
        {
            SqlCommand sqlcommand = GetSqlCommandInstance(ProcedimientosAlmacenados.Consultas);


            sqlcommand.Parameters.AddWithValue(Parametros.Nombre, nombreEstado);
            sqlcommand.Parameters.AddWithValue(Parametros.Id, idPais);

            sqlcommand.Parameters.AddWithValue(Parametros.Operation, 14);

            List<City> ciudades = new List<City>();
            City ciudad = null;

            using (SqlDataReader reader = sqlcommand.ExecuteReader())
            {
                while (reader.Read())
                {
                    ciudad = new City();
                    ciudad.Id = reader.IsDBNull(reader.GetOrdinal("id_ciudad")) ? 0 : (decimal)reader["id_ciudad"];
                    // ciudad.IdCountry = reader.IsDBNull(reader.GetOrdinal("id_pais")) ? 0 : (int)reader["id_pais"];
                    // ciudad.CountryCode = reader.IsDBNull(reader.GetOrdinal("codPais")) ? string.Empty : (string)reader["codPais"];
                    ciudad.Name = reader.IsDBNull(reader.GetOrdinal("nomCiudad")) ? string.Empty : (string)reader["nomCiudad"];
                    //ciudad.State = reader.IsDBNull(reader.GetOrdinal("nomEstado")) ? string.Empty : (string)reader["nomEstado"];
                    // ciudad.CountryName = reader.IsDBNull(reader.GetOrdinal("nomPais")) ? string.Empty : (string)reader["nomPais"];
                    ciudades.Add(ciudad);
                }
            }
            DisposeCommand(sqlcommand);

            return ciudades;
        }


        public void ObtenerVersionFFW()
        {
            // ffw.Source = "Select version_id from ffw "

        }

        public List<Waybill> ObtenerManifiestosRecientes(int idCasillero)
        {
            SqlCommand sqlcommand = GetSqlCommandInstance(ProcedimientosAlmacenados.Consultas);
            sqlcommand.Parameters.AddWithValue(Parametros.IdCasillero, idCasillero);
            sqlcommand.Parameters.AddWithValue(Parametros.Operation, 12);

            List<Waybill> manifiestos = new List<Waybill>();
            Waybill manifiesto = null;

            using (SqlDataReader reader = sqlcommand.ExecuteReader())
            {
                while (reader.Read())
                {
                    manifiesto = new Waybill();
                    manifiesto.Id = (int)reader["manifiesto_id"];
                    manifiesto.WaybillNumber = (string)reader["nrogui"];
                    manifiesto.ReceiptDate = (DateTime)reader["fec_recibo"];
                    manifiesto.WeightLB = (decimal)reader["pesolb"];
                    manifiesto.Pieces = (int)reader["nropaq"];
                    manifiesto.SenderName = (string)reader["rem_nombre"];
                    manifiesto.SenderPhone = (string)reader["rem_telefono"];

                    manifiestos.Add(manifiesto);

                }
            }
            DisposeCommand(sqlcommand);

            return manifiestos;
        }

        public decimal ObtenerTotalDebido(int idCasillero)
        {
            SqlCommand sqlcommand = GetSqlCommandInstance(ProcedimientosAlmacenados.Consultas);
            sqlcommand.Parameters.AddWithValue(Parametros.IdCasillero, idCasillero);
            sqlcommand.Parameters.AddWithValue(Parametros.Operation, 16);

            return (decimal)ScalarSQLCommand(sqlcommand);

        }

        public void ObtenerDetalleGuiaConsolidado(int idCasillero)
        {
            //     rsDetalleguias.Source = "select manifiesto.nrogui as ngui,* from manifiesto left join DETALLECONSOLIDADO on MANIFIESTO.nrogui = detalleconsolidado.nrogui where ISNULL(DETALLECONSOLIDADO.consolidado_id,0) = 0  and ISNULL(manifiesto.tipo_Envio,0) = 0 and ISNULL(fechaanulacion,0) = 0 and fec_recibo > '2017-01-01'" & _
            //"and casillero_id=" & session("cas_casillero_id") & " order by fec_recibo desc"  
        }


        public List<Waybill>BuscarGuiasParaPago(Filter filtro)
        {
            SqlCommand sqlcommand = GetSqlCommandInstance(ProcedimientosAlmacenados.Consultas);
            sqlcommand.Parameters.AddWithValue(Parametros.IdCasillero, filtro.IdPobox);


            if (!string.IsNullOrEmpty(filtro.Waybill))
                sqlcommand.Parameters.AddWithValue(Parametros.WHR, filtro.Waybill);
            if (!string.IsNullOrEmpty(filtro.Tracking))
                sqlcommand.Parameters.AddWithValue(Parametros.Guimia, filtro.Tracking);
            if (!string.IsNullOrEmpty(filtro.SenderName))
                sqlcommand.Parameters.AddWithValue(Parametros.Nombre, filtro.SenderName);
            if (!string.IsNullOrEmpty(filtro.SenderPhone))
                sqlcommand.Parameters.AddWithValue(Parametros.Telefono, filtro.SenderPhone);
            if (filtro.InitialDate.HasValue)
                sqlcommand.Parameters.AddWithValue(Parametros.Fecha, filtro.InitialDate.Value);
            if (filtro.FinalDate.HasValue)
                sqlcommand.Parameters.AddWithValue(Parametros.FechaFinal, filtro.FinalDate.Value);


            sqlcommand.Parameters.AddWithValue(Parametros.Operation, 26);

            List<Waybill> manifiestos = new List<Waybill>();
            Waybill manifiesto = null;

            using (SqlDataReader reader = sqlcommand.ExecuteReader())
            {
                while (reader.Read())
                {
                    manifiesto = new Waybill();
                    manifiesto.Id = (int)reader["manifiesto_id"];
                    manifiesto.WaybillNumber = (string)reader["nrogui"];
                    manifiesto.ReceiptDate = (DateTime)reader["fec_recibo"];
                    manifiesto.WeightLB = (decimal)reader["pesolb"];
                    manifiesto.Pieces = (int)reader["nropaq"];
                    manifiesto.SenderName = (string)reader["rem_nombre"];
                    manifiesto.SenderPhone = (string)reader["rem_telefono"];
                    manifiesto.Total = reader.IsDBNull(reader.GetOrdinal("total")) ? 0 : (decimal)reader["total"];

                    manifiesto.strCurrency = reader.IsDBNull(reader.GetOrdinal("Currency")) ? string.Empty : (string)reader["Currency"];
                    manifiesto.TotalCOP = reader.IsDBNull(reader.GetOrdinal("totalCOP")) ? 0 : (decimal)reader["totalCOP"];

                    manifiesto.TRM = reader.IsDBNull(reader.GetOrdinal("TRM")) ? 0 : (decimal)reader["TRM"];
                    manifiestos.Add(manifiesto);

                }
            }
            DisposeCommand(sqlcommand);

            return manifiestos;
        }


        public List<Waybill> BuscarGuias(Filter filtro)
        {
            SqlCommand sqlcommand = GetSqlCommandInstance(ProcedimientosAlmacenados.Consultas);
            sqlcommand.Parameters.AddWithValue(Parametros.IdCasillero, filtro.IdPobox);


            if (!string.IsNullOrEmpty(filtro.Waybill))
                sqlcommand.Parameters.AddWithValue(Parametros.WHR, filtro.Waybill);
            if (!string.IsNullOrEmpty(filtro.Tracking))
                sqlcommand.Parameters.AddWithValue(Parametros.Guimia, filtro.Tracking);
            if (!string.IsNullOrEmpty(filtro.SenderName))
                sqlcommand.Parameters.AddWithValue(Parametros.Nombre, filtro.SenderName);
            if (!string.IsNullOrEmpty(filtro.SenderPhone))
                sqlcommand.Parameters.AddWithValue(Parametros.Telefono, filtro.SenderPhone);
            if (filtro.InitialDate.HasValue)
                sqlcommand.Parameters.AddWithValue(Parametros.Fecha, filtro.InitialDate.Value);
            if (filtro.FinalDate.HasValue)
                sqlcommand.Parameters.AddWithValue(Parametros.FechaFinal, filtro.FinalDate.Value);


            sqlcommand.Parameters.AddWithValue(Parametros.Operation, 13);

            List<Waybill> manifiestos = new List<Waybill>();
            Waybill manifiesto = null;

            using (SqlDataReader reader = sqlcommand.ExecuteReader())
            {
                while (reader.Read())
                {
                    manifiesto = new Waybill();
                    manifiesto.Id = (int)reader["manifiesto_id"];
                    manifiesto.WaybillNumber = (string)reader["nrogui"];
                    manifiesto.ReceiptDate = (DateTime)reader["fec_recibo"];
                    manifiesto.WeightLB = (decimal)reader["pesolb"];
                    manifiesto.Pieces = (int)reader["nropaq"];
                    manifiesto.SenderName = (string)reader["rem_nombre"];
                    manifiesto.SenderPhone = (string)reader["rem_telefono"];
                    manifiesto.Total = reader.IsDBNull(reader.GetOrdinal("total")) ? 0 : (decimal)reader["total"];

                    manifiestos.Add(manifiesto);

                }
            }
            DisposeCommand(sqlcommand);

            return manifiestos;
        }
        public Company ConsultarCompañia()
        {
            SqlCommand sqlcommand = GetSqlCommandInstance(ProcedimientosAlmacenados.Consultas);
            sqlcommand.Parameters.AddWithValue(Parametros.Operation, 17);


            Company comp = new Company();

            using (SqlDataReader reader = sqlcommand.ExecuteReader())
            {
                while (reader.Read())
                {
                    comp.Name = reader.IsDBNull(reader.GetOrdinal("nombre")) ? string.Empty : (string)reader["nombre"];
                    comp.Address = reader.IsDBNull(reader.GetOrdinal("direccion")) ? string.Empty : (string)reader["direccion"];
                    comp.CityName = reader.IsDBNull(reader.GetOrdinal("ciudad")) ? string.Empty : (string)reader["ciudad"];
                    comp.State = reader.IsDBNull(reader.GetOrdinal("estado")) ? string.Empty : (string)reader["estado"];
                    comp.CountryName = reader.IsDBNull(reader.GetOrdinal("pais")) ? string.Empty : (string)reader["pais"];
                    comp.Zip = reader.IsDBNull(reader.GetOrdinal("zip")) ? string.Empty : (string)reader["zip"];
                    comp.Phone = reader.IsDBNull(reader.GetOrdinal("telefono")) ? string.Empty : (string)reader["telefono"];
                }
            }
            DisposeCommand(sqlcommand);

            return comp;
        }


        public Waybill ConsultaDetalleGuia(int idguia, int idCasillero)
        {
            SqlCommand sqlcommand = GetSqlCommandInstance(ProcedimientosAlmacenados.Consultas);

            sqlcommand.Parameters.AddWithValue(Parametros.IdManifiesto, idguia);
            sqlcommand.Parameters.AddWithValue(Parametros.IdCasillero, idCasillero);
            sqlcommand.Parameters.AddWithValue(Parametros.Operation, 18);

            Waybill detalle = new Waybill();


            using (SqlDataReader reader = sqlcommand.ExecuteReader())
            {
                while (reader.Read())
                {
                    detalle.Id = (int)reader["manifiesto_id"];
                    detalle.DescripcionCodigoRetencion = reader.IsDBNull(reader.GetOrdinal("CrtDescripcion")) ? string.Empty : (string)reader["CrtDescripcion"];
                    detalle.Service = reader.IsDBNull(reader.GetOrdinal("CasilleroServicio")) ? string.Empty : (string)reader["CasilleroServicio"];
                    detalle.PoBoxNumber = reader.IsDBNull(reader.GetOrdinal("NumeroCasillero")) ? string.Empty : (string)reader["NumeroCasillero"];
                    detalle.Alias = reader.IsDBNull(reader.GetOrdinal("Alias")) ? string.Empty : (string)reader["Alias"];
                    detalle.WaybillNumber = reader.IsDBNull(reader.GetOrdinal("NumeroGuia")) ? string.Empty : (string)reader["NumeroGuia"];
                    detalle.ReceiptDate = reader.IsDBNull(reader.GetOrdinal("FechaRecibo")) ? new DateTime() : (DateTime)reader["FechaRecibo"];
                    detalle.AgentCode = reader.IsDBNull(reader.GetOrdinal("Agencia")) ? string.Empty : (string)reader["Agencia"];
                    detalle.Guimia = reader.IsDBNull(reader.GetOrdinal("Guimia")) ? string.Empty : (string)reader["Guimia"];
                    detalle.WeightLB = reader.IsDBNull(reader.GetOrdinal("PesoLb")) ? 0 : (decimal)reader["PesoLb"];
                    detalle.Taxes = reader.IsDBNull(reader.GetOrdinal("Impuestos")) ? 0 : (decimal)reader["Impuestos"];
                    detalle.DeclaredValue = reader.IsDBNull(reader.GetOrdinal("ValorDeclarado")) ? 0 : (decimal)reader["ValorDeclarado"];
                    detalle.Pieces = reader.IsDBNull(reader.GetOrdinal("Pieces")) ? 0 : (int)reader["Pieces"];
                    detalle.RealWeight = reader.IsDBNull(reader.GetOrdinal("PesoReal")) ? 0 : (decimal)reader["PesoReal"];
                    detalle.InsuranceFFw = reader.IsDBNull(reader.GetOrdinal("seguroffw")) ? 0 : (decimal)reader["seguroffw"];
                    detalle.InsuranceAgent = reader.IsDBNull(reader.GetOrdinal("seguroagencia")) ? 0 : (decimal)reader["seguroagencia"];
                    detalle.Freigth = reader.IsDBNull(reader.GetOrdinal("flete")) ? 0 : (decimal)reader["flete"];
                    detalle.PayDate = reader.IsDBNull(reader.GetOrdinal("pagado")) ? (DateTime?)null : (DateTime)reader["pagado"];
                    detalle.Total = reader.IsDBNull(reader.GetOrdinal("total")) ? 0 : (decimal)reader["total"];
                    detalle.CancellationDate = reader.IsDBNull(reader.GetOrdinal("fechaanulacion")) ? (DateTime?)null : (DateTime)reader["fechaanulacion"];
                    detalle.SenderName = reader.IsDBNull(reader.GetOrdinal("NombreRemitente")) ? string.Empty : (string)reader["NombreRemitente"];
                    detalle.SenderPhone = reader.IsDBNull(reader.GetOrdinal("TelefonoRemitente")) ? string.Empty : (string)reader["TelefonoRemitente"];

                    detalle.SenderAddress = reader.IsDBNull(reader.GetOrdinal("DireccionRemitente")) ? string.Empty : (string)reader["DireccionRemitente"];
                    detalle.SenderCity = reader.IsDBNull(reader.GetOrdinal("CiudadRemitente")) ? string.Empty : (string)reader["CiudadRemitente"];
                    detalle.SenderCountry = reader.IsDBNull(reader.GetOrdinal("PaisRemitente")) ? string.Empty : (string)reader["PaisRemitente"];
                    detalle.SenderState = reader.IsDBNull(reader.GetOrdinal("EstadoRemitente")) ? string.Empty : (string)reader["EstadoRemitente"];
                    detalle.SenderZip = reader.IsDBNull(reader.GetOrdinal("ZipRemitente")) ? string.Empty : (string)reader["ZipRemitente"];
                    detalle.DestName = reader.IsDBNull(reader.GetOrdinal("NombreDest")) ? string.Empty : (string)reader["NombreDest"];
                    detalle.DestAddress = reader.IsDBNull(reader.GetOrdinal("DireccionDest")) ? string.Empty : (string)reader["DireccionDest"];
                    detalle.DestCity = reader.IsDBNull(reader.GetOrdinal("CiudadDest")) ? string.Empty : (string)reader["CiudadDest"];
                    detalle.DestCountry = reader.IsDBNull(reader.GetOrdinal("PaisDest")) ? string.Empty : (string)reader["PaisDest"];
                    detalle.DestState = reader.IsDBNull(reader.GetOrdinal("EstadoDest")) ? string.Empty : (string)reader["EstadoDest"];
                    detalle.DestZip = reader.IsDBNull(reader.GetOrdinal("ZipDest")) ? string.Empty : (string)reader["ZipDest"];
                    detalle.DestPhone = reader.IsDBNull(reader.GetOrdinal("TelefonoDest")) ? string.Empty : (string)reader["TelefonoDest"];
                    detalle.AgentName = reader.IsDBNull(reader.GetOrdinal("NombreAgencia")) ? string.Empty : (string)reader["NombreAgencia"];
                    detalle.AgentAddress = reader.IsDBNull(reader.GetOrdinal("DireccionAgencia")) ? string.Empty : (string)reader["DireccionAgencia"];
                    detalle.AgentPhone = reader.IsDBNull(reader.GetOrdinal("TelefonoAgencia")) ? string.Empty : (string)reader["TelefonoAgencia"];
                    detalle.Cuenta = reader.IsDBNull(reader.GetOrdinal("cuenta")) ? string.Empty : (string)reader["cuenta"];
                    detalle.Cajero = reader.IsDBNull(reader.GetOrdinal("Cajero")) ? string.Empty : (string)reader["Cajero"];
                    detalle.strCurrency = reader.IsDBNull(reader.GetOrdinal("strCurrency")) ? string.Empty : (string)reader["strCurrency"];
                    detalle.Description = reader.IsDBNull(reader.GetOrdinal("descripcion")) ? string.Empty : (string)reader["descripcion"];
                }
            }
            DisposeCommand(sqlcommand);

            return detalle;
        }

        //19
        public List<StatusWaybill> ConsultaStatusGuia(int idguia)
        {
            SqlCommand sqlcommand = GetSqlCommandInstance(ProcedimientosAlmacenados.Consultas);

            sqlcommand.Parameters.AddWithValue(Parametros.IdManifiesto, idguia);
            sqlcommand.Parameters.AddWithValue(Parametros.Operation, 19);


            StatusWaybill status = new StatusWaybill();
            List<StatusWaybill> list = new List<StatusWaybill>();

            using (SqlDataReader reader = sqlcommand.ExecuteReader())
            {
                while (reader.Read())
                {
                    status = new StatusWaybill();
                    status.CreatedDate = reader.IsDBNull(reader.GetOrdinal("fecreal")) ? new DateTime() : (DateTime)reader["fecreal"];
                    status.Comment = reader.IsDBNull(reader.GetOrdinal("comentarios")) ? string.Empty : (string)reader["comentarios"];
                    status.StatusDescription = reader.IsDBNull(reader.GetOrdinal("descri")) ? string.Empty : (string)reader["descri"];
                    list.Add(status);
                }
            }
            DisposeCommand(sqlcommand);

            return list;
        }

        //20
        public List<Adjunto> ConsultaAdjuntosGuia(int idguia)
        {
            SqlCommand sqlcommand = GetSqlCommandInstance(ProcedimientosAlmacenados.Consultas);

            sqlcommand.Parameters.AddWithValue(Parametros.IdManifiesto, idguia);
            sqlcommand.Parameters.AddWithValue(Parametros.Operation, 20);

            Adjunto adj = new Adjunto();
            List<Adjunto> list = new List<Adjunto>();

            using (SqlDataReader reader = sqlcommand.ExecuteReader())
            {
                while (reader.Read())
                {
                    adj = new Adjunto();
                    adj.High = reader.IsDBNull(reader.GetOrdinal("paq_alto")) ? 0 : (decimal)reader["paq_alto"];
                    adj.Long = reader.IsDBNull(reader.GetOrdinal("paq_largo")) ? 0 : (decimal)reader["paq_largo"];
                    adj.Width = reader.IsDBNull(reader.GetOrdinal("paq_ancho")) ? 0 : (decimal)reader["paq_ancho"];
                    adj.Volume = reader.IsDBNull(reader.GetOrdinal("paq_volumen")) ? 0 : (decimal)reader["paq_volumen"];
                    adj.Weight = reader.IsDBNull(reader.GetOrdinal("paq_peso")) ? 0 : (decimal)reader["paq_peso"];
                    adj.WaybillNumber = reader.IsDBNull(reader.GetOrdinal("paq_nrogui")) ? string.Empty : (string)reader["paq_nrogui"];

                    list.Add(adj);
                }
            }
            DisposeCommand(sqlcommand);

            return list;
        }


        //21
        public List<Contenido> ConsultaContenidosGuia(int idguia)
        {
            SqlCommand sqlcommand = GetSqlCommandInstance(ProcedimientosAlmacenados.Consultas);

            sqlcommand.Parameters.AddWithValue(Parametros.IdManifiesto, idguia);
            sqlcommand.Parameters.AddWithValue(Parametros.Operation, 21);

            Contenido adj = new Contenido();
            List<Contenido> list = new List<Contenido>();

            using (SqlDataReader reader = sqlcommand.ExecuteReader())
            {
                while (reader.Read())
                {
                    adj = new Contenido();
                    adj.Cantidad = reader.IsDBNull(reader.GetOrdinal("cnt_cantidad")) ? 0 : (int)reader["cnt_cantidad"];
                    adj.Detalle = reader.IsDBNull(reader.GetOrdinal("cnt_detalle")) ? string.Empty : (string)reader["cnt_detalle"];

                    list.Add(adj);
                }
            }
            DisposeCommand(sqlcommand);

            return list;
        }


        //22
        public List<ArchivoAdjunto> ConsultaArchivoAdjuntosGuia(int idguia)
        {
            SqlCommand sqlcommand = GetSqlCommandInstance(ProcedimientosAlmacenados.Consultas);

            sqlcommand.Parameters.AddWithValue(Parametros.IdManifiesto, idguia);
            sqlcommand.Parameters.AddWithValue(Parametros.Operation, 22);

            ArchivoAdjunto adj = new ArchivoAdjunto();
            List<ArchivoAdjunto> list = new List<ArchivoAdjunto>();

            using (SqlDataReader reader = sqlcommand.ExecuteReader())
            {
                while (reader.Read())
                {
                    adj = new ArchivoAdjunto();
                    adj.Id = reader.IsDBNull(reader.GetOrdinal("ARC_ARCHIVO_ID")) ? 0 : (int)reader["ARC_ARCHIVO_ID"];
                    adj.Name = reader.IsDBNull(reader.GetOrdinal("ARC_NOMBRE")) ? string.Empty : (string)reader["ARC_NOMBRE"];
                    adj.Path = reader.IsDBNull(reader.GetOrdinal("ARC_PATH")) ? string.Empty : (string)reader["ARC_PATH"];

                    list.Add(adj);
                }
            }
            DisposeCommand(sqlcommand);

            return list;
        }

        //23
        public List<AditionalCharge> ConsultaAditionalChargesGuia(int idguia)
        {
            SqlCommand sqlcommand = GetSqlCommandInstance(ProcedimientosAlmacenados.Consultas);

            sqlcommand.Parameters.AddWithValue(Parametros.IdManifiesto, idguia);
            sqlcommand.Parameters.AddWithValue(Parametros.Operation, 23);

            AditionalCharge adj = new AditionalCharge();
            List<AditionalCharge> list = new List<AditionalCharge>();

            using (SqlDataReader reader = sqlcommand.ExecuteReader())
            {
                while (reader.Read())
                {
                    adj = new AditionalCharge();
                    adj.Id = reader.IsDBNull(reader.GetOrdinal("cId")) ? 0 : (int)reader["cId"];
                    adj.Value = reader.IsDBNull(reader.GetOrdinal("valor")) ? 0 : (decimal)reader["valor"];
                    adj.Total = reader.IsDBNull(reader.GetOrdinal("total")) ? 0 : (decimal)reader["total"];
                    adj.Concept = reader.IsDBNull(reader.GetOrdinal("concepto")) ? string.Empty : (string)reader["concepto"];
                    adj.Cantidad = reader.IsDBNull(reader.GetOrdinal("cantidad")) ? 0 : (int)reader["cantidad"];

                    list.Add(adj);
                }
            }
            DisposeCommand(sqlcommand);

            return list;
        }


        #endregion


    }
}
