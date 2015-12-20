{ stdenv, libxslt, gzip, coreutils, ... }: stdenv.mkDerivation {
  name = "vmware-bundle-extract";
  src = ./.;

  buildInputs = [ libxslt gzip coreutils ];
  preferLocalBuild = true;

  configurePhase = ''
    runHook preConfigure
    substituteInPlace ./vmware-bundle.sh --subst-var-by coreutils ${coreutils} --subst-var-by libxslt ${libxslt} --subst-var-by gzip ${gzip} --subst-var-by out $out
    runHook postConfigure
  '';
  installPhase = ''
    runHook preInstall
    install -m0755 -d $out/share/vmware-bundle/ $out/bin/
    install -m0755 vmware-bundle.sh *.xsl $out/share/vmware-bundle/
    ln -s ../share/vmware-bundle/vmware-bundle.sh $out/bin/vmware-bundle_extract-bundle-component
    ln -s ../share/vmware-bundle/vmware-bundle.sh $out/bin/vmware-bundle_extract-component
    runHook postInstall
  '';
}
