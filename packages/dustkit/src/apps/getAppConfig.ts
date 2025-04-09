import { type AppConfig, appConfigInput } from "./appConfig";

export async function getAppConfig({
  url,
}: { url: string }): Promise<AppConfig> {
  const config = await fetch(url)
    .then((res) => res.json())
    .then(appConfigInput.assert);

  const configUrl = new URL(url);
  const startUrl = new URL(config.startUrl ?? ".", url);
  if (startUrl.origin !== configUrl.origin) {
    throw new Error(
      `App config \`startUrl\` origin ("${startUrl.origin}") did not match app config origin ("${configUrl.origin}").`,
    );
  }

  return {
    ...config,
    startUrl: startUrl.toString(),
  };
}
