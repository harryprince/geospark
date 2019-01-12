package geospark
import org.datasyslab.geosparksql.utils.{Adapter, GeoSparkSQLRegistrator}
import org.datasyslab.geosparkviz.core.Serde.GeoSparkVizKryoRegistrator

object Main {
  def register_gis(spark: SparkSession) = {
      GeoSparkSQLRegistrator.registerAll(spark)
    // spark.udf.register("hello", (name: String) => {
    //   "Hello, " + name + "! - From Scala"
    // })
  }
}