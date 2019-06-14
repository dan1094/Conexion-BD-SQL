using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
//using Entidades;


namespace Conexion
{
	public class Usuario
    {
        private int id;

        public int Id
        {
            get { return id; }
            set { id = value; }
        }
        private string nombre;

        public string Nombre
        {
            get { return nombre; }
            set { nombre = value; }
        }

        private string contrasenia;

        public string Contrasenia
        {
            get { return contrasenia; }
            set { contrasenia = value; }
        }
    }
	
    public class Conexion
    {
        public static void Actualizar(Usuario usuario)
        {
            string conexion = "data source=CBPBOGOTA;Initial Catalog=PruebaUsuarios; User ID=sa;Password=10Box%Ap";
            string qry = string.Format("EXEC [dbo].[SP_USUARIOS] @NOMBRE = {0},@CONTRASENIA = {1},@ID = {2} @OPERACION = 1"
                , usuario.Nombre, usuario.Contrasenia, usuario.Id);


            //  DataTable dt = new DataTable();
            SqlConnection conexionSql = new SqlConnection(conexion); //se configura la conexión
            try
            {
                conexionSql.Open(); //se abre la conexión
                SqlDataAdapter da = new SqlDataAdapter(qry, conexionSql);
                SqlCommand cmd = new SqlCommand(qry, conexionSql);
                cmd.ExecuteNonQuery();

            }
            catch (Exception)
            {

                throw;
            }
            finally
            {
                conexionSql.Close();
            }
        }
		
        public static void Crear(Usuario usuario)
        {
            string conexion = "data source=CBPBOGOTA;Initial Catalog=PruebaUsuarios; User ID=sa;Password=10Box%Ap";
            string qry = string.Format("EXEC [dbo].[SP_USUARIOS] @NOMBRE = {0},@CONTRASENIA = {1}, @OPERACION = 0 "
                , usuario.Nombre, usuario.Contrasenia);


            SqlConnection conexionSql = new SqlConnection(conexion); //se configura la conexión
            try
            {
                conexionSql.Open(); //se abre la conexión
                SqlDataAdapter da = new SqlDataAdapter(qry, conexionSql);
                SqlCommand cmd = new SqlCommand(qry, conexionSql);
                cmd.ExecuteNonQuery();

            }
            catch (Exception)
            {

                throw;
            }
            finally
            {
                conexionSql.Close();
            }
        }
		
        public static void Borrar(int idUsuario)
        {
            string conexion = "data source=CBPBOGOTA;Initial Catalog=PruebaUsuarios; User ID=sa;Password=10Box%Ap";
            string qry = string.Format("EXEC [dbo].[SP_USUARIOS] @ID = {0}, @OPERACION = 3 "
                , idUsuario);

            SqlConnection conexionSql = new SqlConnection(conexion); //se configura la conexión
            try
            {
                conexionSql.Open(); //se abre la conexión
                SqlDataAdapter da = new SqlDataAdapter(qry, conexionSql);
                SqlCommand cmd = new SqlCommand(qry, conexionSql);
                cmd.ExecuteNonQuery();

            }
            catch (Exception)
            {

                throw;
            }
            finally
            {
                conexionSql.Close();
            }
        }

        public static Usuario ConsultarUno(int idUsuario)
        {
            string conexion = "data source=CBPBOGOTA;Initial Catalog=PruebaUsuarios; User ID=sa;Password=10Box%Ap";
            string qry = string.Format("EXEC [dbo].[SP_USUARIOS] @ID = {0}, @OPERACION = 2 "
                , idUsuario);
            Usuario usuario = new Usuario();
            SqlConnection conexionSql = new SqlConnection(conexion); //se configura la conexión

            try
            {
                DataTable dt = new DataTable();
                conexionSql.Open(); //se abre la conexión
                SqlDataAdapter da = new SqlDataAdapter(qry, conexionSql);
                da.Fill(dt);

                foreach (DataRowView item in dt.DefaultView)
                {
                    usuario.Id = Convert.ToInt32(item["ID"].ToString());
                    usuario.Nombre = item["NOMBRE"].ToString();
                    usuario.Contrasenia = item["CONTRASENIA"].ToString();
                }
            }
            catch (Exception)
            {

                throw;
            }
            finally
            {
                conexionSql.Close();
            }
            return usuario;
        }

        public static Usuario ConsultarPorNombre(string nombre)
        {
            string conexion = "data source=CBPBOGOTA;Initial Catalog=PruebaUsuarios; User ID=sa;Password=10Box%Ap";
            string qry = string.Format("EXEC [dbo].[SP_USUARIOS] @NOMBRE = {0}, @OPERACION = 5 "
                , nombre);
            Usuario usuario = new Usuario();
            SqlConnection conexionSql = new SqlConnection(conexion); //se configura la conexión

            try
            {
                DataTable dt = new DataTable();
                conexionSql.Open(); //se abre la conexión
                SqlDataAdapter da = new SqlDataAdapter(qry, conexionSql);
                da.Fill(dt);

                foreach (DataRowView item in dt.DefaultView)
                {
                    usuario.Id = Convert.ToInt32(item["ID"].ToString());
                    usuario.Nombre = item["NOMBRE"].ToString();
                    usuario.Contrasenia = item["CONTRASENIA"].ToString();
                }
            }
            catch (Exception)
            {

                throw;
            }
            finally
            {
                conexionSql.Close();
            }
            return usuario;
        }

    }
}
