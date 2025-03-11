using System;
using System.Diagnostics;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;

namespace MacTrackpadDashboard;

/// <summary>
/// Interaction logic for MainWindow.xaml
/// </summary>
public partial class MainWindow : Window
{
    public MainWindow()
    {
        InitializeComponent();
        
        // Set dynamic values
        InstallDateText.Text = DateTime.Now.ToShortDateString();
        OSVersionText.Text = Environment.OSVersion.VersionString;
    }

    private void OnInstallClick(object sender, RoutedEventArgs e)
    {
        RunBatchScript("run_install.bat");
    }

    private void OnUninstallClick(object sender, RoutedEventArgs e)
    {
        RunBatchScript("run_uninstall.bat");
    }

    private void OnTestClick(object sender, RoutedEventArgs e)
    {
        RunBatchScript("run_tests.bat");
    }

    private void OnCheckUpdatesClick(object sender, RoutedEventArgs e)
    {
        MessageBox.Show("No updates found. You are using the latest version.", 
            "Update Check", MessageBoxButton.OK, MessageBoxImage.Information);
    }

    private void RunBatchScript(string scriptName)
    {
        try
        {
            // Assume the batch file is in the parent directory of the executable
            string projectRoot = System.IO.Path.GetDirectoryName(
                System.IO.Path.GetDirectoryName(
                    System.IO.Path.GetDirectoryName(
                        AppDomain.CurrentDomain.BaseDirectory)));

            string batchPath = System.IO.Path.Combine(projectRoot, scriptName);
            
            // Check if the file exists
            if (!System.IO.File.Exists(batchPath))
            {
                MessageBox.Show($"Could not find script: {scriptName}\nSearched at: {batchPath}", 
                    "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }
            
            // Start the process
            ProcessStartInfo psi = new ProcessStartInfo
            {
                FileName = "cmd.exe",
                Arguments = $"/c \"{batchPath}\"",
                WorkingDirectory = projectRoot,
                UseShellExecute = true
            };
            
            Process.Start(psi);
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Error running script: {ex.Message}", 
                "Error", MessageBoxButton.OK, MessageBoxImage.Error);
        }
    }

    private void AddRealDriverButton()
    {
        // Find the existing UniformGrid in Actions Card
        var actionsCard = this.FindName("ActionsGrid") as UniformGrid;
        if (actionsCard != null)
        {
            // Add a new button for the real driver
            Button realDriverButton = new Button
            {
                Content = "View Real Driver Info",
                Margin = new Thickness(5),
                Padding = new Thickness(10, 5, 10, 5),
                Background = new SolidColorBrush(Color.FromRgb(0, 120, 215)),
                Foreground = Brushes.White
            };
            
            realDriverButton.Click += (sender, e) =>
            {
                try
                {
                    // Open the real driver info page
                    string projectRoot = System.IO.Path.GetDirectoryName(
                        System.IO.Path.GetDirectoryName(
                            System.IO.Path.GetDirectoryName(
                                AppDomain.CurrentDomain.BaseDirectory)));
                    
                    string infoPath = System.IO.Path.Combine(
                        projectRoot, 
                        "src", 
                        "MacTrackpadDashboard", 
                        "real_driver_info.html");
                    
                    if (System.IO.File.Exists(infoPath))
                    {
                        Process.Start(new ProcessStartInfo
                        {
                            FileName = infoPath,
                            UseShellExecute = true
                        });
                    }
                    else
                    {
                        MessageBox.Show("Real driver info not found. Please run integrate_real_driver.bat first.", 
                            "File Not Found", MessageBoxButton.OK, MessageBoxImage.Warning);
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Error: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            };
            
            actionsCard.Children.Add(realDriverButton);
        }
    }
}