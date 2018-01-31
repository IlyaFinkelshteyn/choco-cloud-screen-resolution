import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.remote.DesiredCapabilities;
import org.openqa.selenium.remote.RemoteWebDriver;
import org.testng.annotations.AfterTest;
import org.testng.annotations.BeforeTest;
import org.testng.annotations.Test;

import java.net.MalformedURLException;
import java.net.URL;

import static org.junit.Assert.*;

public class ChromeTest {

  private WebDriver driver;

  @BeforeTest
  public void beforeTest() throws MalformedURLException {
    DesiredCapabilities capabilities = new DesiredCapabilities();
    capabilities.setBrowserName("chrome");

    driver = new RemoteWebDriver(new URL("http://localhost:4444/wd/hub"), capabilities);
    driver.get("http://www.whatismyscreenresolution.com/");
  }

  @Test
  public void main() {
    WebElement element = driver.findElement(By.id("resolutionNumber"));
    assertEquals("1366 x 768", element.getText());
  }

  @AfterTest
  public void afterTest() {
    driver.quit();
  }
}
