using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Entidades;
using System.Data.SqlClient;

namespace Data
{
    public class AlertasCRUD : Conexion
    {

        public Alert CrearAlerta(Alert alerta)
        {
          
            SqlCommand sqlcommand = GetSqlCommandInstance(ProcedimientosAlmacenados.CrearAlertas);

            sqlcommand.Parameters.AddWithValue(Parametros.alr_guimia, alerta.Guimia);
            sqlcommand.Parameters.AddWithValue(Parametros.alr_comentario, alerta.Comment );
            sqlcommand.Parameters.AddWithValue(Parametros.alr_casillero, alerta.PoBoxNumber);
            sqlcommand.Parameters.AddWithValue(Parametros.alr_body, alerta.Body);
            sqlcommand.Parameters.AddWithValue(Parametros.alr_tienda, alerta.Store);
            sqlcommand.Parameters.AddWithValue(Parametros.alr_carrier, alerta.Carrier);
            sqlcommand.Parameters.AddWithValue(Parametros.alr_valor, alerta.ValueAlert);
            sqlcommand.Parameters.AddWithValue(Parametros.alr_descripcion, alerta.Description);
            sqlcommand.Parameters.AddWithValue(Parametros.alr_seguro, alerta.Insurance);

            Alert respuesta = new Alert();

            using (SqlDataReader reader = sqlcommand.ExecuteReader())
            {
                while (reader.Read())
                {                  

                    respuesta.Id = (int)reader["alr_alerta_id"];
                    respuesta.Date = (DateTime)reader["alr_fecha"];
                    respuesta.Guimia = reader.IsDBNull(reader.GetOrdinal("alr_guimia")) ? string.Empty : (string)reader["alr_guimia"];
                    respuesta.PoBoxNumber = reader.IsDBNull(reader.GetOrdinal("alr_casillero")) ? string.Empty : (string)reader["alr_casillero"];
                }
            }
            DisposeCommand(sqlcommand);

            return respuesta;

        }

        public void CrearAdjuntoAlerta()
        {

        }

        public List<Alert> BuscarAlertasCasillero(Filter filter)
        {
            SqlCommand sqlcommand = GetSqlCommandInstance(ProcedimientosAlmacenados.Consultas);

            sqlcommand.Parameters.AddWithValue(Parametros.IdCasillero, filter.IdPobox);

            if (filter.InitialDate.HasValue)
                sqlcommand.Parameters.AddWithValue(Parametros.Fecha, filter.InitialDate.Value);
            if (filter.FinalDate.HasValue)
                sqlcommand.Parameters.AddWithValue(Parametros.FechaFinal, filter.FinalDate.Value);
            sqlcommand.Parameters.AddWithValue(Parametros.Operation, 6);

            List<Alert> alertas = new List<Alert>();
            Alert alerta = null;
            
            using (SqlDataReader reader = sqlcommand.ExecuteReader())
            {
                while (reader.Read())
                {
                    alerta = new Alert();
                    alerta.Id = (int)reader["alr_alerta_id"];
                    alerta.Date = (DateTime)reader["alr_fecha"];
                    alerta.Guimia = reader.IsDBNull(reader.GetOrdinal("alr_guimia")) ? string.Empty : (string)reader["alr_guimia"];
                    alerta.PoBoxNumber = reader.IsDBNull(reader.GetOrdinal("alr_casillero")) ? string.Empty : (string)reader["alr_casillero"];
                    alerta.Body = reader.IsDBNull(reader.GetOrdinal("alr_body")) ? string.Empty : (string)reader["alr_body"];
                    alerta.Store = reader.IsDBNull(reader.GetOrdinal("alr_tienda")) ? string.Empty : (string)reader["alr_tienda"];
                    alerta.ValueAlert = reader.IsDBNull(reader.GetOrdinal("alr_valor")) ? string.Empty : (string)reader["alr_valor"];
                    alerta.Description = reader.IsDBNull(reader.GetOrdinal("alr_descripcion")) ? string.Empty : (string)reader["alr_descripcion"];
                    alerta.Insurance = reader.IsDBNull(reader.GetOrdinal("alr_seguro")) ? false : (bool)reader["alr_seguro"]; 
                    alerta.Address = reader.IsDBNull(reader.GetOrdinal("alr_direccion")) ? string.Empty : (string)reader["alr_direccion"];
                    alerta.Comment = reader.IsDBNull(reader.GetOrdinal("alr_comentario")) ? string.Empty : (string)reader["alr_comentario"];
                    alertas.Add(alerta);
                }
            }
            DisposeCommand(sqlcommand);

            return alertas;

        }


        public int BorrarAlerta(int id)
        {
            SqlCommand sqlcommand = GetSqlCommandInstance(ProcedimientosAlmacenados.Consultas);
            sqlcommand.Parameters.AddWithValue(Parametros.Operation, 32);

            sqlcommand.Parameters.AddWithValue(Parametros.Id, id);

            return (int)ScalarSQLCommand(sqlcommand);
        }

    }
}
