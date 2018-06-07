import os

def test_decode_ok(urls, monkeypatch, fake_daemon, tmpdir, ctm_file):
    # Don't decode for real
    def start_decoding(conf, file_name, seg_file, scripts_dir, output_dir,
                       system="base", silent=True,
                       status_function=lambda x, y: print(x)):
        # Everything went fine
        return 0

    monkeypatch.setattr(fake_daemon.tools, 'start_decoding',
                        start_decoding)

    # Create a fake ctm (the decoding was successful
    output_ctm_path = os.path.join(fake_daemon.output_dir, ctm_file)
    os.makedirs(os.path.dirname(output_ctm_path), exist_ok=True)

    with open(output_ctm_path, "w") as f:
        f.write("audition_alexandre_juniac 1 1749.79 0.24 monsieur "
                "1.00 audition_alexandre_juniac#F0_F-S280#1749.06:1761.37#")
        f.write("audition_alexandre_juniac 1 1750.03 0.04 le 1.00 "
                "audition_alexandre_juniac#F0_F-S280#1749.06:1761.37#")

    (r, msg) = fake_daemon.decode_file_list(urls['process_list_url'],
                                            urls['download_url'],
                                            urls['update_process_url'],
                                            urls['upload_url'],
                                            urls['get_file_url'])

    assert msg == "Everything went fine"
    assert r == 0


def test_decode_fail_no_ctm(urls, monkeypatch, fake_daemon, tmpdir, ctm_file,
                            wav_file):
    # Don't decode for real
    def start_decoding(conf, file_name, seg_file, scripts_dir, output_dir,
                       system="base", silent=True,
                       status_function=lambda x, y: print(x)):
        # Everything went fine
        return 0

    monkeypatch.setattr(fake_daemon.tools, 'start_decoding',
                        start_decoding)

    (r, msg) = fake_daemon.decode_file_list(urls['process_list_url'],
                                            urls['download_url'],
                                            urls['update_process_url'],
                                            urls['upload_url'],
                                            urls['get_file_url'])

    assert msg == "Empty file. Error decoding {}".format(wav_file)
    assert r == -2
