using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using MySql.Data.MySqlClient;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Rolsa_Technologies.Pages
{
    public class EV_Station_LocatorModel : PageModel
    {
        [BindProperty]
        public string Address { get; set; }
        public List<EVStation> Stations { get; set; }

        public async Task<IActionResult> OnPostAsync()
        {
            if (string.IsNullOrEmpty(Address)) return Page();

            var (lat, lng) = await GetCoordinatesAsync(Address);
            if (lat == 0 && lng == 0) return Page();

            Stations = GetNearbyStations(lat, lng, 10);
            return Page();
        }

        private async Task<(double, double)> GetCoordinatesAsync(string address)
        {
            // Use an external API (e.g., OpenStreetMap Nominatim) to convert address to lat/lng
            await Task.Delay(100); // Simulate async API call
            return (53.3900, -2.5969); // Sample lat/lng for Warrington
        }

        private List<EVStation> GetNearbyStations(double lat, double lng, double rangeKm)
        {
            var stations = new List<EVStation>();
            string connectionString = "server=localhost;database=db_resla_technologies;user=root;password=saroot";
            using (var connection = new MySqlConnection(connectionString))
            {
                connection.Open();
                using (var command = new MySqlCommand("CALL GetNearbyStations(@lat, @lng, @rangeKm);", connection))
                {
                    command.Parameters.AddWithValue("@lat", lat);
                    command.Parameters.AddWithValue("@lng", lng);
                    command.Parameters.AddWithValue("@rangeKm", rangeKm);
                    using (var reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            stations.Add(new EVStation
                            {
                                StationName = reader.GetString("StationName"),
                                Distance = reader.GetDouble("distance"),
                                StationAvailability = reader.GetString("StationAvailability"),
                                StationAppPayment = reader.GetBoolean("StationAppPayment")
                            });
                        }
                    }
                }
            }
            return stations;
        }
    }

    public class EVStation
    {
        public string StationName { get; set; }
        public double Distance { get; set; }
        public string StationAvailability { get; set; }
        public bool StationAppPayment { get; set; }
    }
}
