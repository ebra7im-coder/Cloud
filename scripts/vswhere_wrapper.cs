using System;
using System.Diagnostics;
using System.Collections.Generic;
using System.Reflection;
using System.IO;

/// <summary>
/// vswhere.exe wrapper — makes Flutter 3.22 (which searches VS 16/2019)
/// accept Visual Studio 2022 (version 17.x) on GitHub Actions windows-2022.
///
/// How it works:
/// 1. Intercepts the -version 16 argument and changes it to -version 17
/// 2. Calls the real vswhere.exe (renamed .orig) with the updated args
/// 3. In the JSON output, patches installationVersion 17.x → 16.11.x
///    so Flutter's version check passes
/// </summary>
class VsWhereWrapper
{
    static int Main(string[] argv)
    {
        // Path to the real vswhere (we rename it to .orig before replacing)
        string thisExe = Assembly.GetExecutingAssembly().Location;
        string realVsWhere = Path.ChangeExtension(thisExe, ".orig");

        if (!File.Exists(realVsWhere))
        {
            Console.Error.WriteLine("vswhere.orig not found: " + realVsWhere);
            return 1;
        }

        // Patch args: replace -version 16 with -version 17
        var args = new List<string>(argv);
        for (int i = 0; i < args.Count - 1; i++)
        {
            if (args[i] == "-version" && args[i + 1] == "16")
            {
                args[i + 1] = "17";
                break;
            }
        }

        // Build quoted argument string
        var quotedArgs = string.Join(" ", args.ConvertAll(a => "\"" + a.Replace("\"", "\\\"") + "\""));

        var psi = new ProcessStartInfo(realVsWhere, quotedArgs)
        {
            RedirectStandardOutput = true,
            RedirectStandardError  = true,
            UseShellExecute        = false
        };

        var proc = Process.Start(psi);
        string output = proc.StandardOutput.ReadToEnd();
        string errors = proc.StandardError.ReadToEnd();
        proc.WaitForExit();

        // Patch JSON output: change version 17.x or 18.x to 16.11.x
        if (output.TrimStart().StartsWith("["))
        {
            output = output
                .Replace("\"installationVersion\":\"17.", "\"installationVersion\":\"16.11.")
                .Replace("\"installationVersion\": \"17.", "\"installationVersion\": \"16.11.")
                .Replace("\"installationVersion\":\"18.", "\"installationVersion\":\"16.11.")
                .Replace("\"installationVersion\": \"18.", "\"installationVersion\": \"16.11.");
        }

        Console.Write(output);
        if (!string.IsNullOrEmpty(errors))
            Console.Error.Write(errors);

        return proc.ExitCode;
    }
}
