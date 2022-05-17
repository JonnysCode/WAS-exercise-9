package tools;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.io.FileUtils;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import cartago.*;

/*
An artifact crawling a hypermedia environment starting from an entry point URL
(entryPoint)
*/
public class HypermediaCrawler extends Artifact {

  private static final String BASE_URL = "http://api.interactions.ics.unisg.ch/hypermedia-environment/was/";
  private static final String FILE_PATH = "./src/org/temp-os.xml";
  private String entryPoint;

  public void init(String url) {
    this.entryPoint = url;
  }

  @OPERATION
  public void searchEnvironment(String relationType, OpFeedbackParam<String> filePath) {

    List<String> discovered = new ArrayList<String>();
    List<String> checked = new ArrayList<String>();

    discovered.add(entryPoint);

    while (!discovered.isEmpty()) {
      String next = discovered.remove(0);
      checked.add(next);

      Document doc;
      try {
        doc = Jsoup.connect(BASE_URL + next).get();

        Elements links = doc.select("a");
        for (Element link : links) {
          String href = link.attr("href");

          if (link.toString().contains(relationType)) {
            log("Discovered relation at " + href);
            filePath.set(fetchToFile(href));
            return;
          }

          if (!checked.contains(href) && !discovered.contains(href)) {
            discovered.add(href);
          }
        }
      } catch (IOException e) {
        e.printStackTrace();
      }
    }
  }

  private String fetchToFile(String url) throws IOException {
    Document doc = Jsoup.connect(url).get();

    final File f = new File(FILE_PATH);
    FileUtils.writeStringToFile(f, doc.outerHtml(), StandardCharsets.UTF_8);
    log("Discovered file available at " + FILE_PATH);
    return FILE_PATH;
  }

}
